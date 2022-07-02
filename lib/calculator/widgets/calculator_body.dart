import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tasse_forfettario/assets.dart';
import 'package:tasse_forfettario/calculator/provider/provider.dart';
import 'package:tasse_forfettario/calculator/widgets/double_num_text_field.dart';
import 'package:tasse_forfettario/calculator/widgets/dropdown_list_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

extension on int {
  // converts a negative number to 0, and returns its string representation.
  String toPositiveString() {
    final number = this <= 0 ? 0 : this;
    return number.toString();
  }
}

/// {@template calculator_body}
/// Body of the CalculatorPage.
///
/// Add what it does
/// {@endtemplate}
class CalculatorBody extends StatefulHookConsumerWidget {
  /// {@macro calculator_body}
  const CalculatorBody({super.key});

  @override
  ConsumerState<CalculatorBody> createState() => _CalculatorBodyState();
}

class _CalculatorBodyState extends ConsumerState<CalculatorBody> {
  late int selectedYear;
  int selectedCoefficiente = 67;

  @override
  void initState() {
    super.initState();
    // if supported, or the last in the supported list
    final currentYear = DateTime.now().year;
    selectedYear = aliquotaInpsPerAnno.containsKey(currentYear)
        ? currentYear
        : aliquotaInpsPerAnno.keys.last;
  }

  @override
  Widget build(BuildContext context) {
    final totalEarningsController = useTextEditingController();
    final accontiPrecInpsController = useTextEditingController();
    final accontiPrecImpostaSostitutivaController = useTextEditingController();

    final aliquotaImpostaSostitutiva = useState(Aliquota.nuovaAttivita);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: DropdownButtonHideUnderline(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Calcolatore tasse regime forfettario',
                    style: context.textStyles.h4.bold
                        .copyWith(color: Colors.black),
                  ),
                  subtitle: const Text(
                    '''* Il seguente tool non è stato sviluppato da un commercialista, le informazioni qui riportate potrebbero non essere corrette.''',
                  ),
                ),
                const SizedBox(height: 40),
                DropdownListTile<int>(
                  value: selectedYear,
                  labelText: "Seleziona l'anno per cui vuoi calcolare le tasse",
                  options: aliquotaInpsPerAnno.keys,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedYear = value);
                  },
                ),
                const SizedBox(height: 16),
                DoubleNumTextField(
                  labelText: 'Totale entrate',
                  textEdititingController: totalEarningsController,
                  hintText: "Inserisci l'importo",
                ),
                const SizedBox(height: 16),
                DropdownListTile<int>(
                  value: selectedCoefficiente,
                  labelText: 'Seleziona il coefficiente di redditività',
                  options: coefficientiRedditivita,
                  formatDisplayValue: (value) => '$value%',
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedCoefficiente = value);
                  },
                ),
                const SizedBox(height: 16),
                DoubleNumTextField(
                  labelText:
                      """Totale acconti INPS $selectedYear versati nell'anno precedente""",
                  textEdititingController: accontiPrecInpsController,
                  hintText: '0.00€',
                ),
                const SizedBox(height: 16),
                DoubleNumTextField(
                  labelText:
                      """Totale acconti Imposta Sostitutiva $selectedYear versati nell'anno precedente""",
                  textEdititingController:
                      accontiPrecImpostaSostitutivaController,
                  hintText: '0.00€',
                ),
                const SizedBox(height: 16),
                DropdownButton<Aliquota>(
                  value: aliquotaImpostaSostitutiva.value,
                  items: Aliquota.values
                      .map(
                        (aliquota) => DropdownMenuItem(
                          value: aliquota,
                          child: Text(
                            '${aliquota.percentage}%',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    aliquotaImpostaSostitutiva.value = value;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 20,
                    ),
                  ),
                  onPressed: () {
                    ref.read(calculatorProvider.notifier).calculate(
                          year: selectedYear,
                          earnings: double.parse(totalEarningsController.text),
                          coefficienteRedditivita: selectedCoefficiente,
                          aliquota: aliquotaImpostaSostitutiva.value,
                          totaleAccontiINPSPrecedenti: accontiPrecInpsController
                                  .text.isEmpty
                              ? 0.0
                              : double.parse(accontiPrecInpsController.text),
                          totaleAccontiImpostaSostitutivaPrecedenti:
                              accontiPrecImpostaSostitutivaController
                                      .text.isEmpty
                                  ? 0.0
                                  : double.parse(
                                      accontiPrecImpostaSostitutivaController
                                          .text,
                                    ),
                        );
                  },
                  child: Text(
                    'Calcola',
                    style: context.textStyles.bodyText1.bold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Consumer(
                  builder: (_, ref, __) {
                    final tasseResult = ref.watch(calculatorProvider);
                    if (tasseResult == null) return const SizedBox();

                    final dateTextStyle =
                        context.textStyles.bodyText1.bold.copyWith(
                      color: Colors.grey,
                    );
                    final labelStyle = context.textStyles.bodyText1.regular;
                    final amountStyle = context.textStyles.bodyText1
                        .copyWith(color: Colors.grey);

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.all(
                        20,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '30/06/${selectedYear + 1}',
                                style: dateTextStyle,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Saldo imposta sostitutiva (rif. $selectedYear):',
                                      style: labelStyle,
                                    ),
                                  ),
                                  Text(
                                    '€ ${tasseResult.saldoImpostaSostitutiva.toPositiveString()}',
                                    style: amountStyle,
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Saldo contributi INPS (rif. $selectedYear):',
                                      style: labelStyle,
                                    ),
                                  ),
                                  Text(
                                    '€ ${tasseResult.saldoContributiINPS.toPositiveString()}',
                                    style: amountStyle,
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Acconto prima rata imposta sostitutiva (rif. ${selectedYear + 1}):',
                                      style: labelStyle,
                                    ),
                                  ),
                                  Text(
                                    '€ ${tasseResult.accontoPrimaRataImpostaSostitutiva.toPositiveString()}',
                                    style: amountStyle,
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Acconto prima rata INPS (rif. ${selectedYear + 1}):',
                                      style: labelStyle,
                                    ),
                                  ),
                                  Text(
                                    '€ ${tasseResult.accontoPrimaRataINPS.toPositiveString()}',
                                    style: amountStyle,
                                  )
                                ],
                              ),
                            ],
                          ),
                          Divider(
                            height: 40,
                            thickness: 2,
                            color: Colors.grey.shade200,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '30/11/${selectedYear + 1}',
                                style: dateTextStyle,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Acconto seconda rata imposta sostitutiva (rif. ${selectedYear + 1}):',
                                      style: labelStyle,
                                    ),
                                  ),
                                  Text(
                                    '€ ${tasseResult.accontoSecondaRataImpostaSostitutiva.toPositiveString()}',
                                    style: amountStyle,
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Acconto seconda rata INPS (rif. ${selectedYear + 1}):',
                                      style: labelStyle,
                                    ),
                                  ),
                                  Text(
                                    '€ ${tasseResult.accontoSecondaRataINPS.toPositiveString()}',
                                    style: amountStyle,
                                  )
                                ],
                              ),
                            ],
                          ),
                          Divider(
                            height: 40,
                            thickness: 2,
                            color: Colors.grey.shade200,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Totale tasse previste:',
                                  style: context.textStyles.h5.bold,
                                ),
                              ),
                              Text(
                                '€ ${tasseResult.total.toPositiveString()}',
                                style: context.textStyles.h5.bold,
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                IconButton(
                  iconSize: 40,
                  onPressed: () {
                    launchUrlString(
                      'https://github.com/nank1ro/tasse_forfettario',
                    );
                  },
                  icon: Image.asset(Assets.githubMark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
