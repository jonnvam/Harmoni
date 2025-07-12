import 'package:flutter/material.dart';

class CarruselNativo extends StatefulWidget {
  const CarruselNativo({super.key});

  @override
  State<CarruselNativo> createState() => _CarruselNativoState();
}

class _CarruselNativoState extends State<CarruselNativo> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<String> images = [
    'assets/images/carousel/t1.jpg',
    'assets/images/carousel/t2.jpg',
    'assets/images/carousel/t3.jpg',
    'assets/images/carousel/t4.jpg',
    'assets/images/carousel/t5.jpg',
    'assets/images/carousel/t6.jpg',
  
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll cada 5 segundos
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 5));
      if (_controller.hasClients) {
        int nextPage = (_currentPage + 1) % images.length;
        _controller.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() => _currentPage = nextPage);
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          width: 238,
          child: PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    images[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        
      ],
    );
  }
}





