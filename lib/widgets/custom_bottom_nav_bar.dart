import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar(
      {super.key, required this.currentIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed, // Tipo fixo para customizações
      showSelectedLabels: false, // Oculta rótulos dos itens selecionados
      showUnselectedLabels: false, // Oculta rótulos dos itens não selecionados
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/icon/lists.png', width: 24, height: 24),
          label:
              '', // Define o label como string vazia para garantir que não apareça
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icon/sino.png', width: 24, height: 24),
          label: '', // String vazia
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icon/download.png', width: 24, height: 24),
          label: '', // String vazia
        ),
      ],
    );
  }
}
