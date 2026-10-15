# r00tvpn для Android

Клиент [Mihomo](https://github.com/MetaCubeX/mihomo) для Android — мобильная версия
[r00tvpn](https://github.com/soulless4235/r00tvpn-). Форк [FlClash](https://github.com/chen08209/FlClash)
под собственным брендом. Версия для iPhone появится позже в этом же проекте.

## Чем отличается от FlClash

- Внешний вид как у r00tvpn для ПК («Графит»): главная с карточкой подключения и списком серверов
  по странам, разделы ПК в нижнем меню, графитовые цвета с оранжевым акцентом, шрифт Onest
- Своё имя и идентификатор приложения (`io.github.soulless4235.r00tvpn`), ссылки `r00tvpn://`
  (`clash://` и `clashmeta://` для импорта подписок тоже работают)
- **Без Firebase**: нет аналитики и отчётов о сбоях, приложение ничего не отправляет разработчикам
- Проверка обновлений — по релизам этого репозитория
- Русский язык интерфейса по умолчанию
- User-Agent подписок `clash.meta r00tvpn/v<версия> …`, как у десктопной версии
- DNS по умолчанию — Cloudflare и Google

## Установка

APK публикуются в [Releases](https://github.com/soulless4235/r00tvpn-mobile/releases).
Для большинства телефонов нужен файл `arm64-v8a`. Постоянная ссылка на последнюю версию
(с релиза после 1.0.0 имена файлов без номера версии):
https://github.com/soulless4235/r00tvpn-mobile/releases/latest/download/r00tvpn-android-arm64-v8a.apk

## Сборка

Собирает GitHub Actions (`.github/workflows/android.yml`): Flutter 3.47.6, Go 1.27.1, NDK r28c, Java 17.

```bash
git clone --recurse-submodules https://github.com/soulless4235/r00tvpn-mobile.git
cd r00tvpn-mobile
flutter pub get
dart setup.dart android
```

Релиз публикуется по тегу версии (`1.0.0`, `1.0.0-beta.1`). Для подписи релизов своим ключом задайте
секреты репозитория `KEYSTORE` (keystore в base64), `KEY_ALIAS`, `STORE_PASSWORD`, `KEY_PASSWORD`;
без них APK подписывается отладочным ключом и получает идентификатор с `.dev` (для проверки;
обновить такую установку релизной сборкой не получится — только удалить и поставить заново).
Описание релиза берётся из `.github/release-notes/<тег>.md`, если такой файл есть.

## Лицензия и авторство

[GPL-3.0](LICENSE).

- [FlClash](https://github.com/chen08209/FlClash) — chen08209, исходный проект этого форка
- [Mihomo](https://github.com/MetaCubeX/mihomo) — MetaCubeX, прокси-ядро
