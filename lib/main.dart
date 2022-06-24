import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

const aliquotaInpsPerAnno = {
  2020: 25.72,
  2021: 25.98,
  2022: 26.23,
};

const aliquoteImpostaSostitutiva = [
  5,
  15,
];

const coefficienteRedditiva = 0.67;

class Result {
  const Result(
    this._saldoImpostaSostitutiva,
    this._saldoInps, {
    required this.imponibile,
    required this.accontiInpsPrec,
    required this.accontiImpostaSostitutivaPrec,
  });

  final double imponibile;
  final double _saldoImpostaSostitutiva;
  final double _saldoInps;
  final double accontiInpsPrec;
  final double accontiImpostaSostitutivaPrec;

  double get saldoImpostaSostitutiva =>
      (_saldoImpostaSostitutiva - accontiImpostaSostitutivaPrec)
          .truncateToDouble();
  double get saldoInps => (_saldoInps - accontiInpsPrec).truncateToDouble();
  double get accontiImpostaSostitutiva => _saldoImpostaSostitutiva;
  double get accontiInps => (_saldoInps * .8).truncateToDouble();
  double get total =>
      saldoImpostaSostitutiva +
      saldoInps +
      accontiImpostaSostitutiva +
      accontiInps;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final TextEditingController totalEarningsController;
  late final TextEditingController accontiPrecedentiInpsController;
  late final TextEditingController
      accontiPrecedentiImpostaSostitutivaController;
  late int selectedYear;
  int aliquotaImpostaSostitutiva = 15;
  Result? result;

  @override
  void initState() {
    super.initState();
    totalEarningsController = TextEditingController();
    accontiPrecedentiInpsController = TextEditingController();
    accontiPrecedentiImpostaSostitutivaController = TextEditingController();

    // Initialize the selectedYear with the current one,
    // if supported, or the last in the supported list
    final currentYear = DateTime.now().year;
    selectedYear = aliquotaInpsPerAnno.containsKey(currentYear)
        ? currentYear
        : aliquotaInpsPerAnno.keys.last;
  }

  @override
  void dispose() {
    totalEarningsController.dispose();
    accontiPrecedentiInpsController.dispose();
    accontiPrecedentiImpostaSostitutivaController.dispose();
    super.dispose();
  }

  void calcolaRisultato() {
    final totalEarnings = double.parse(totalEarningsController.text);

    final imponibile = totalEarnings * coefficienteRedditiva;
    final saldoImpostaSostitutiva =
        imponibile * (aliquotaImpostaSostitutiva / 100);

    final aliquotaInpsAnno = aliquotaInpsPerAnno[selectedYear]!;
    final saldoInps = imponibile * (aliquotaInpsAnno / 100);

    final accontiPrecedentiInpsValue =
        accontiPrecedentiInpsController.text.isEmpty
            ? 0.0
            : double.parse(accontiPrecedentiInpsController.text);

    final accontiPrecedentiImpostaValue =
        accontiPrecedentiImpostaSostitutivaController.text.isEmpty
            ? 0.0
            : double.parse(accontiPrecedentiImpostaSostitutivaController.text);

    setState(() {
      result = Result(
        saldoImpostaSostitutiva.truncateToDouble(),
        saldoInps.truncateToDouble(),
        imponibile: imponibile.truncateToDouble(),
        accontiImpostaSostitutivaPrec: accontiPrecedentiImpostaValue,
        accontiInpsPrec: accontiPrecedentiInpsValue,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Column(
            children: [
              DropdownButton<int>(
                value: selectedYear,
                items: aliquotaInpsPerAnno.keys
                    .map(
                      (anno) => DropdownMenuItem(
                        value: anno,
                        child: Text(
                          anno.toString(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedYear = value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: totalEarningsController,
                decoration:
                    InputDecoration(hintText: "Totale guadagni $selectedYear"),
              ),
              const SizedBox(height: 16),
              const Text("Coefficiente di redditività: 67%"),
              const Divider(height: 16),
              TextField(
                controller: accontiPrecedentiInpsController,
                decoration: InputDecoration(
                    hintText: "Totale acconti ${selectedYear - 1} (INPS)"),
              ),
              const Divider(height: 16),
              TextField(
                controller: accontiPrecedentiImpostaSostitutivaController,
                decoration: InputDecoration(
                    hintText:
                        "Totale acconti ${selectedYear - 1} (Imposta sostitutiva)"),
              ),
              const Divider(height: 16),
              DropdownButton<int>(
                value: aliquotaImpostaSostitutiva,
                items: aliquoteImpostaSostitutiva
                    .map(
                      (aliquota) => DropdownMenuItem(
                        value: aliquota,
                        child: Text(
                          "$aliquota%",
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => aliquotaImpostaSostitutiva = value);
                },
              ),
              const Divider(height: 16),
              ElevatedButton(
                onPressed: () {
                  calcolaRisultato();
                },
                child: const Text("Calcola"),
              ),
              const Divider(height: 16),
              if (result != null)
                Column(
                  children: [
                    Row(
                      children: [
                        Text("Saldo imposta sostitutiva (rif. $selectedYear):"),
                        Text(
                          result!.saldoImpostaSostitutiva <= 0
                              ? "0"
                              : result!.saldoImpostaSostitutiva
                                  .toString()
                                  .padRight(2, "0"),
                          style: textTheme.bodyText1!,
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text("Saldo contributi INPS (rif. $selectedYear):"),
                        Text(
                          result!.saldoInps <= 0
                              ? "0"
                              : result!.saldoInps.toString().padRight(2, "0"),
                          style: textTheme.bodyText1!,
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                            "Acconti imposta sostitutiva (rif. ${selectedYear + 1}):"),
                        Text(
                          result!.accontiImpostaSostitutiva
                              .toString()
                              .padRight(2, "0"),
                          style: textTheme.bodyText1!,
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                            "Acconti contributi INPS (rif. ${selectedYear + 1}):"),
                        Text(
                          result!.accontiInps.toString().padRight(2, "0"),
                          style: textTheme.bodyText1!,
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text("Totale tasse previste:"),
                        Text(
                          result!.total.toString().padRight(2, "0"),
                          style: textTheme.bodyText1!,
                        )
                      ],
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
