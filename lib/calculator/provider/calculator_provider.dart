import 'package:riverpod/riverpod.dart';
import 'package:tasse_forfettario/calculator/domain/tasse_result.dart';

const coefficientiRedditivita = [40, 54, 62, 67, 78, 86];

const aliquotaInpsPerAnno = {
  2020: 25.72,
  2021: 25.98,
  2022: 26.23,
};

enum Aliquota {
  nuovaAttivita(5),
  vecchiaAttivita(15);

  const Aliquota(this.percentage);

  final int percentage;
}

final calculatorProvider =
    StateNotifierProvider.autoDispose<Calculator, TasseResult?>((ref) {
  return Calculator();
});

class Calculator extends StateNotifier<TasseResult?> {
  Calculator() : super(null);

  void calculate({
    required int year,
    required double earnings,
    required int coefficienteRedditivita,
    required Aliquota aliquota,
    double totaleAccontiINPSPrecedenti = 0,
    double totaleAccontiImpostaSostitutivaPrecedenti = 0,
  }) {
    final imponibile = earnings * (coefficienteRedditivita / 100);
    final saldoImpostaSostitutiva = imponibile * (aliquota.percentage / 100);

    final aliquotaInpsAnno = aliquotaInpsPerAnno[year]!;
    final saldoInps = imponibile * (aliquotaInpsAnno / 100);

    final aliquotaInpsAnnoSuccessivo = aliquotaInpsPerAnno.containsKey(year + 1)
        ? aliquotaInpsPerAnno[year + 1]!
        : aliquotaInpsAnno + 0.25;
    final saldoInpsAnnoSuccessivo =
        imponibile * (aliquotaInpsAnnoSuccessivo / 100);

    final totaleAccontiINPS = saldoInpsAnnoSuccessivo * .8;
    final accontoPrimaRataINPS = totaleAccontiINPS / 2;
    final accontoSecondaRataINPS = totaleAccontiINPS / 2;

    final accontoPrimaRataImpostaSostitutiva = saldoImpostaSostitutiva / 2;
    final accontoSecondaRataImpostaSostitutiva = saldoImpostaSostitutiva / 2;

    state = TasseResult(
      saldoContributiINPS: (saldoInps - totaleAccontiINPSPrecedenti).round(),
      saldoImpostaSostitutiva:
          (saldoImpostaSostitutiva - totaleAccontiImpostaSostitutivaPrecedenti)
              .round(),
      accontoPrimaRataINPS: accontoPrimaRataINPS.round(),
      accontoSecondaRataINPS: accontoSecondaRataINPS.round(),
      accontoPrimaRataImpostaSostitutiva:
          accontoPrimaRataImpostaSostitutiva.round(),
      accontoSecondaRataImpostaSostitutiva:
          accontoSecondaRataImpostaSostitutiva.round(),
    );
  }
}
