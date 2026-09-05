import 'package:flutter/material.dart';

void main() {
  runApp(const Score41App());
}

class Score41App extends StatelessWidget {
  const Score41App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '41Score',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int jugadores = 3;

  final nombres = List.generate(6, (_) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("41Score")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Nueva partida",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: jugadores,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Número de jugadores",
              ),
              items: List.generate(
                5,
                (i) => DropdownMenuItem(
                  value: i + 2,
                  child: Text("${i + 2} jugadores"),
                ),
              ),
              onChanged: (v) => setState(() => jugadores = v!),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: jugadores,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: nombres[i],
                    decoration: InputDecoration(
                      labelText: "Jugador ${i + 1}",
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                final lista = List.generate(
                  jugadores,
                  (i) => nombres[i].text.trim().isEmpty
                      ? "Jugador ${i + 1}"
                      : nombres[i].text.trim(),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PartidaPage(lista),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(15),
                child: Text("Empezar partida"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PartidaPage extends StatefulWidget {
  final List<String> nombres;

  const PartidaPage(this.nombres, {super.key});

  @override
  State<PartidaPage> createState() => _PartidaPageState();
}

class _PartidaPageState extends State<PartidaPage> {
  late List<int> puntos;
  late List<bool> reenganchado;
  late List<bool> eliminado;
  final historial = <String>[];

  @override
  void initState() {
    super.initState();
    puntos = List.filled(widget.nombres.length, 0);
    reenganchado = List.filled(widget.nombres.length, false);
    eliminado = List.filled(widget.nombres.length, false);
  }
    void cerrarRonda(int ganador) {
    final controlador = List.generate(
      widget.nombres.length,
      (_) => TextEditingController(text: "0"),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("${widget.nombres[ganador]} ha cerrado"),
        content: SizedBox(
          width: 320,
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(widget.nombres.length, (i) {
                if (i == ganador || eliminado[i]) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: controlador[i],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: widget.nombres[i],
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text("Guardar"),
            onPressed: () {
              setState(() {
                historial.add("${widget.nombres[ganador]} cerró");

                for (int i = 0; i < widget.nombres.length; i++) {
                  if (i == ganador || eliminado[i]) continue;

                  final suma = int.tryParse(controlador[i].text) ?? 0;
                  puntos[i] += suma;

                  if (puntos[i] >= 151 && !reenganchado[i]) {
                    reenganchado[i] = true;
                    puntos[i] = 41;
                    historial.add("${widget.nombres[i]} se reenganchó");
                  } else if (puntos[i] >= 151 && reenganchado[i]) {
                    eliminado[i] = true;
                    historial.add("${widget.nombres[i]} eliminado");
                  }
                }

                comprobarGanador();
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void comprobarGanador() {
    final vivos = <int>[];

    for (int i = 0; i < eliminado.length; i++) {
      if (!eliminado[i]) vivos.add(i);
    }

    if (vivos.length == 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text("🏆 Fin de partida"),
            content: Text("${widget.nombres[vivos.first]} ha ganado."),
            actions: [
              FilledButton(
                child: const Text("Salir"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      });
    }
  }

  void finPartida() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Finalizar partida"),
        content: const Text("¿Seguro que quieres terminar la partida?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text("Sí"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("41Score"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: finPartida,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: widget.nombres.length,
              itemBuilder: (_, i) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Text(
                          widget.nombres[i],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          eliminado[i]
                              ? "ELIMINADO"
                              : "Faltan ${151 - puntos[i]} puntos para 151",
                          style: TextStyle(
                            fontSize: 13,
                            color: eliminado[i]
                                ? Colors.red
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${puntos[i]}",
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed:
                                eliminado[i] ? null : () => cerrarRonda(i),
                            child: Text("${widget.nombres[i]} ha cerrado"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Historial",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: historial.isEmpty
                        ? const Center(child: Text("Sin rondas todavía"))
                        : ListView.builder(
                            itemCount: historial.length,
                            itemBuilder: (_, i) => ListTile(
                              dense: true,
                              leading: const Icon(Icons.history),
                              title: Text(historial[i]),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
