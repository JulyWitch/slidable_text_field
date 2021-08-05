final _fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
final _ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

String fixNumbers(String text) {
  for (var i = 0; i < 10; i++) {
   text= text.replaceAll(_fa[i], i.toString()).replaceAll(_ar[i], i.toString());
  }
  return text;
}
