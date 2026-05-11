import 'package:intl/intl.dart';

String formatRupiah(int amount) {
  final formatter = NumberFormat('#,###', 'id_ID');
  return formatter.format(amount).replaceAll(',', '.');
}

String formatCompactAmount(int amount) {
  if (amount >= 1000000000) {
    final val = amount / 1000000000;
    return '${_trimDecimal(val)}M';
  } else if (amount >= 1000000) {
    final val = amount / 1000000;
    return '${_trimDecimal(val)}jt';
  } else if (amount >= 1000) {
    final val = amount / 1000;
    return '${_trimDecimal(val)}rb';
  }
  return formatRupiah(amount);
}

String _trimDecimal(double val) {
  if (val == val.roundToDouble()) {
    return val.toInt().toString();
  }
  return val.toStringAsFixed(1);
}

String formatTanggalSingkat(DateTime date) {
  return DateFormat('d MMM yyyy', 'id_ID').format(date);
}

String formatWaktu(DateTime date) {
  return DateFormat('HH:mm', 'id_ID').format(date);
}

String formatTanggalWaktuSingkat(DateTime date) {
  return DateFormat('d MMM, HH:mm', 'id_ID').format(date);
}

String formatBulanTahun(DateTime date) {
  return DateFormat('MMMM yyyy', 'id_ID').format(date);
}
