const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
require("dotenv").config();

admin.initializeApp();

const BUHO_MODE = process.env.BUHO_MODE || "SIMULADO";
const BUHO_EMAIL = process.env.BUHO_EMAIL || "";
const BUHO_PASSWORD = process.env.BUHO_PASSWORD || "";
const BUHO_BASE_URL = "https://cedulas.buholegal.com/api";

function normalizarTexto(texto = "") {
  return texto
    .toString()
    .trim()
    .replace(/\s+/g, " ")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toUpperCase();
}

function esPsicologia(carrera = "") {
  return normalizarTexto(carrera).includes("PSICOLOG");
}

async function loginBuhoReal() {
  const response = await axios.post(`${BUHO_BASE_URL}/login/`, {
    email: BUHO_EMAIL,
    password: BUHO_PASSWORD,
  });

  const token =
    response.data.access ||
    response.data.token ||
    response.data.key ||
    response.data.access_token;

  if (!token) {
    throw new Error("Búho Legal no devolvió token válido");
  }

  return token;
}

async function consultarBuhoReal(cedula) {
  const token = await loginBuhoReal();

  const response = await axios.get(`${BUHO_BASE_URL}/cedula/${cedula}/`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  const data = response.data;

  return {
    cedulaBuholegal: String(data.cedula || data.numero || cedula),
    nombreBuholegal:
      data.nombreCompleto ||
      data.nombre_completo ||
      `${data.nombre || ""} ${data.paterno || ""} ${data.materno || ""}`.trim(),
    carreraBuholegal: data.carrera || data.profesion || data.titulo || "",
    institucionBuholegal:
      data.institucion || data.universidad || data.institucion_emisora || "",
  };
}

async function consultarBuhoSimulado(cedula, nombreCompletoIne) {
  return {
    cedulaBuholegal: String(cedula),
    nombreBuholegal: nombreCompletoIne,
    carreraBuholegal: "LICENCIATURA EN PSICOLOGIA",
    institucionBuholegal: "UNIVERSIDAD DEMO",
  };
}

exports.validarCedulaPsicologo = functions.https.onRequest(async (req, res) => {
  try {
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");

    if (req.method === "OPTIONS") {
      return res.status(204).send("");
    }

    if (req.method !== "POST") {
      return res.status(405).json({
        ok: false,
        message: "Método no permitido. Usa POST.",
      });
    }

    const { uid, cedula, nombreCompletoIne } = req.body;

    if (!uid || !cedula || !nombreCompletoIne) {
      return res.status(400).json({
        ok: false,
        message: "Faltan uid, cedula o nombreCompletoIne.",
      });
    }

    const resultado =
      BUHO_MODE === "REAL"
        ? await consultarBuhoReal(cedula)
        : await consultarBuhoSimulado(cedula, nombreCompletoIne);

    const coincideNombre =
      normalizarTexto(resultado.nombreBuholegal) ===
      normalizarTexto(nombreCompletoIne);

    const coincideCedula =
      String(resultado.cedulaBuholegal).trim() === String(cedula).trim();

    const carreraPsicologia = esPsicologia(resultado.carreraBuholegal);

    const estadoValidacion =
      coincideNombre && coincideCedula && carreraPsicologia
        ? "PREVALIDADO"
        : "RECHAZADO";

    const motivoRechazo =
      estadoValidacion === "PREVALIDADO"
        ? ""
        : "No coincide nombre, cédula o carrera profesional con Búho Legal.";

    const payload = {
      uid,
      nombreBuholegal: normalizarTexto(resultado.nombreBuholegal),
      cedulaBuholegal: String(resultado.cedulaBuholegal),
      carreraBuholegal: normalizarTexto(resultado.carreraBuholegal),
      institucionBuholegal: resultado.institucionBuholegal,

      coincideNombre,
      coincideCedula,
      esPsicologia: carreraPsicologia,

      estadoValidacion,
      puedeEjercer: false,
      requiereRevisionManual: estadoValidacion !== "PREVALIDADO",
      motivoRechazo,

      fuentePrevalidacion:
        BUHO_MODE === "REAL" ? "BUHOLEGAL_REAL" : "BUHOLEGAL_SIMULADO",

      fechaActualizacion: admin.firestore.FieldValue.serverTimestamp(),
    };

    await admin
      .firestore()
      .collection("verificacionesProfesionales")
      .doc(uid)
      .set(payload, { merge: true });

    await admin
      .firestore()
      .collection("usuariosPsicologos")
      .doc(uid)
      .set(
        {
          estadoValidacion,
          puedeEjercer: false,
          verificationUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

    return res.status(200).json({
      ok: true,
      estadoValidacion,
      resultado: {
        ...payload,
        fechaActualizacion: new Date().toISOString(),
      },
    });
  } catch (error) {
    console.error("Error validarCedulaPsicologo:", error.response?.data || error);

    return res.status(500).json({
      ok: false,
      message: "Error al validar cédula profesional.",
      detalle: error.response?.data || error.message,
    });
  }
});