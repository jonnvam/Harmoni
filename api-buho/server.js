require("dotenv").config();

const express = require("express");
const axios = require("axios");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const BUHO_MODE = process.env.BUHO_MODE || "SIMULADO";
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

function coincidenNombresFlexible(nombreBuho, nombreIne) {
  const buho = normalizarTexto(nombreBuho).split(" ").filter(Boolean);
  const ine = normalizarTexto(nombreIne).split(" ").filter(Boolean);

  if (buho.length === 0 || ine.length === 0) return false;

  const coincidencias = ine.filter((palabra) => buho.includes(palabra));

  return coincidencias.length >= 3;
}

async function loginBuho() {
  const response = await axios.post(`${BUHO_BASE_URL}/login/`, {
    email: process.env.BUHO_EMAIL,
    password: process.env.BUHO_PASSWORD,
  });

  const token =
    response.data.access ||
    response.data.token ||
    response.data.key ||
    response.data.access_token;

  if (!token) {
    throw new Error("Búho Legal no devolvió token.");
  }

  return token;
}

async function consultarBuhoReal(cedula) {
  const token = await loginBuho();

  const response = await axios.get(`${BUHO_BASE_URL}/cedula/${cedula}/`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  const rawData = response.data;
  const data = Array.isArray(rawData) ? rawData[0] : rawData;

  console.log("RESPUESTA REAL BUHO:", JSON.stringify(rawData, null, 2));

  return {
    cedulaBuholegal: String(data?.cedula || cedula),
    nombreBuholegal: `${data?.nombre || ""} ${data?.paterno || ""} ${
      data?.materno || ""
    }`.trim(),
    carreraBuholegal: data?.carrera || "",
    institucionBuholegal: data?.universidad || "",
    raw: rawData,
  };
}

async function consultarBuhoSimulado(cedula, nombreCompletoIne) {
  return {
    cedulaBuholegal: String(cedula),
    nombreBuholegal: nombreCompletoIne,
    carreraBuholegal: "LICENCIATURA EN PSICOLOGIA",
    institucionBuholegal: "UNIVERSIDAD DEMO",
    raw: { modo: "SIMULADO" },
  };
}

app.get("/", (req, res) => {
  res.json({
    ok: true,
    message: "API Harmoni Búho Legal funcionando 🚀",
    mode: BUHO_MODE,
  });
});

app.post("/validar-cedula", async (req, res) => {
  try {
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

    const coincideNombre = coincidenNombresFlexible(
      resultado.nombreBuholegal,
      nombreCompletoIne
    );

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
        : "La cédula existe, pero no coincidieron completamente nombre, cédula o carrera.";

    return res.json({
      ok: true,
      estadoValidacion,
      resultado: {
        uid,
        nombreBuholegal: normalizarTexto(resultado.nombreBuholegal),
        cedulaBuholegal: resultado.cedulaBuholegal,
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
        raw: resultado.raw,
      },
    });
  } catch (error) {
    console.error("ERROR BUHO:", error.response?.data || error.message);

    return res.status(500).json({
      ok: false,
      message: "Error al validar cédula.",
      detalle: error.response?.data || error.message,
    });
  }
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Servidor corriendo en puerto ${PORT}`);
});