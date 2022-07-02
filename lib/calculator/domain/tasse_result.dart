import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'tasse_result.freezed.dart';

@freezed
class TasseResult with _$TasseResult {
  const TasseResult._();

  const factory TasseResult({
    required int saldoContributiINPS,
    required int saldoImpostaSostitutiva,
    required int accontoPrimaRataINPS,
    required int accontoSecondaRataINPS,
    required int accontoPrimaRataImpostaSostitutiva,
    required int accontoSecondaRataImpostaSostitutiva,
  }) = _TasseResult;

  int get total =>
      saldoImpostaSostitutiva +
      saldoContributiINPS +
      accontoPrimaRataINPS +
      accontoSecondaRataINPS +
      accontoPrimaRataImpostaSostitutiva +
      accontoSecondaRataImpostaSostitutiva;
}
