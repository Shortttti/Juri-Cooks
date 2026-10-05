# Juri Cooks — Flutter app

نسخة Flutter أصلية ومهيأة للجوال من مخبز جوري. فيها واجهة مخبز متحركة، تصنيفات وبحث، وصفات، تبديل جرامات/أكواب، مفضلة، صينية تجهيز محفوظة، تقييم وملاحظات، وضع طبخ خطوة بخطوة، مؤقت فرن، اختيار وصفة عشوائية، وإضافة وصفات.

## تشغيل التطبيق

يتطلب Flutter SDK حديثًا مع Android Studio أو Xcode لتشغيل محاكي/جهاز.

```bash
cd flutter_app
flutter create --project-name juri_cooks --platforms android,ios,web .
flutter pub get
flutter run
```

الأمر الأول يضيف ملفات المنصات الأصلية إلى هذا الهيكل، ثم يعمل الأمر التالي على تثبيت الاعتمادات وتشغيل المشروع.

على جهاز أندرويد موصول:

```bash
flutter run -d <device-id>
```

لبناء APK تجريبي:

```bash
flutter build apk --release
```

وGitHub Actions يبني APK أندرويد عند تحديث مجلد التطبيق، ويضعه في Artifact باسم `juri-cooks-android` لمدة 14 يومًا. لبناء نسخة iOS على جهاز حقيقي يلزم macOS وXcode وتوقيع Apple.

لبناء تطبيق ويب:

```bash
flutter build web --release
```

بيانات المفضلة والصينية والوصفات التي تضيفينها تحفظ محليًا على الجهاز باستخدام `shared_preferences`.
