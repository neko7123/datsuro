class AppLegal {
  AppLegal._();

  static const _privacy = {
    'en': '''DATSURŌ Privacy Policy · Version 2

This app has no account system, app-owned server, or analytics service. Your profile is stored on this device using the app's local storage. The app does not send your diary or profile to a DATSURŌ server.

Data stored: your chosen username, preferences, home coordinates, radius, diary text and photos, confirmed escape events, earned stamps, and notification settings. Photos are copied into the app's private files. Location is used to compare readings with your home radius. When you leave that radius, the app saves an escape event and may ask the operating system's geocoder for a country code for a country stamp. Raw tracking coordinates are not added to escape history. The operating system and geocoding provider may process coordinates under their own privacy terms.

Background tracking is optional. On Android it runs as a location foreground service with a persistent notification. The app filters noisy readings and saves only detected exit events; accuracy, connectivity, battery settings, force-stop, and device policies can interrupt detection. Location is not used for advertising.

Notifications are scheduled locally. If you export a ZIP backup, it can include profile data, home coordinates, diary notes, and photos. You choose where to share or store it; recipients and other apps may copy it. Imports replace the on-device profile. Deleting app data does not erase exported files or copies held by your device backup provider.

You can change settings, export a backup, or delete the profile in the app. Data remains until you delete it or uninstall the app, subject to operating-system backup behavior. The app does not claim that local data is encrypted by this app. Protect your device and exported backups. Location and notification access can be changed in system settings. This policy may change with a later app version; a new version will be shown before use.''',
    'ja': '''脱籠 プライバシーポリシー · 第2版

本アプリにはアカウント、運営者のサーバー、分析サービスはありません。プロフィールは端末内に保存され、脱籠のサーバーへ日記やプロフィールを送信しません。

保存する情報：ユーザー名、設定、自宅の座標、半径、日記の文章と写真、検出した外出イベント、獲得スタンプ、通知設定。写真はアプリ専用領域にコピーします。位置情報は自宅の半径との比較に使います。半径の外に出たとき、外出イベントを保存し、国別スタンプ用にOSのジオコーダーへ国コードを問い合わせる場合があります。追跡した座標そのものは外出履歴に保存しません。OSやジオコーディング事業者による座標の処理には各社の規約が適用されます。

バックグラウンド追跡は任意です。Androidでは常時通知を表示する位置情報フォアグラウンドサービスとして動作します。誤検知を減らして外出イベントだけを保存しますが、精度、通信、電池設定、強制終了、端末の制限により検出が中断することがあります。広告目的で位置情報を使いません。

通知は端末内で予約します。ZIPバックアップにはプロフィール、自宅座標、日記、写真が含まれる場合があります。共有先や保存先は利用者が選び、受け取ったアプリや相手が複製する可能性があります。読み込んだバックアップは現在のプロフィールを置き換えます。アプリ内データを削除しても、書き出したファイルや端末のバックアップ事業者のコピーは削除されません。

設定変更、バックアップの書き出し、プロフィール削除はアプリ内で行えます。データは削除またはアプリをアンインストールするまで保持されます（OSのバックアップ動作を除く）。本アプリ独自の暗号化を行うとは表明しません。端末とバックアップを安全に管理してください。位置情報・通知の許可はシステム設定から変更できます。ポリシーを改定する場合は利用前に新しい内容を表示します。''',
    'ko': '''脱籠 개인정보 처리방침 · 버전 2

이 앱에는 계정, 앱 운영 서버 또는 분석 서비스가 없습니다. 프로필은 기기에 저장되며 일기나 프로필을 DATSURŌ 서버로 전송하지 않습니다.

저장되는 정보: 사용자 이름, 설정, 집 좌표, 반경, 일기 글과 사진, 감지된 외출 이벤트, 획득 스탬프, 알림 설정. 사진은 앱 전용 저장 공간에 복사됩니다. 위치는 집 반경과 비교하는 데 사용합니다. 반경을 벗어나면 외출 이벤트를 저장하고 국가 스탬프를 위해 운영체제 지오코더에 국가 코드를 요청할 수 있습니다. 원시 추적 좌표는 외출 기록에 저장하지 않습니다. 운영체제와 지오코딩 제공자의 처리에는 각자의 개인정보 약관이 적용됩니다.

백그라운드 추적은 선택 사항입니다. Android에서는 지속 알림이 표시되는 위치 포그라운드 서비스로 실행됩니다. 부정확한 측정을 걸러 외출 이벤트만 저장하지만 정확도, 연결, 배터리 설정, 강제 종료 및 기기 정책에 따라 감지가 중단될 수 있습니다. 위치를 광고에 사용하지 않습니다.

알림은 기기에서 예약합니다. ZIP 백업에는 프로필, 집 좌표, 일기와 사진이 포함될 수 있습니다. 공유 및 저장 위치는 사용자가 선택하며 다른 앱이나 수신자가 복사할 수 있습니다. 백업을 가져오면 현재 프로필을 교체합니다. 앱 데이터를 삭제해도 내보낸 파일이나 기기 백업 제공자의 사본은 삭제되지 않습니다.

앱에서 설정을 바꾸고 백업을 내보내거나 프로필을 삭제할 수 있습니다. 데이터는 직접 삭제하거나 앱을 제거할 때까지 보관됩니다(OS 백업 동작 제외). 앱 자체 암호화를 제공한다고 보장하지 않습니다. 기기와 백업을 안전하게 관리하세요. 위치와 알림 권한은 시스템 설정에서 변경할 수 있습니다. 정책이 바뀌면 새 버전을 사용 전에 표시합니다.''',
    'zh': '''脱籠 隐私政策 · 第2版

本应用没有账户、应用自有服务器或分析服务。资料保存在本机，不会发送到 DATSURŌ 服务器。

保存的信息包括：用户名、设置、家的坐标、半径、日记文字和照片、检测到的外出事件、获得的印章及通知设置。照片复制到应用专属文件。位置用于与家的半径比较。离开半径时会保存外出事件，并可能向操作系统地理编码服务查询国家代码以发放国家印章。原始追踪坐标不会写入外出记录。操作系统和地理编码服务可能依据各自条款处理坐标。

后台追踪为可选功能。Android 使用带持续通知的位置前台服务运行。应用会过滤不可靠读数并只保存检测到的离家事件；定位精度、网络、电池设置、强制停止和设备策略都可能中断检测。位置不会用于广告。

通知在本机安排。导出的 ZIP 备份可能包含资料、家的坐标、日记和照片。由你选择分享和存储位置，接收方或其他应用可能复制文件。导入备份会替换本机资料。删除应用数据不会删除已导出的文件或设备备份服务保存的副本。

你可以在应用内更改设置、导出备份或删除资料。数据会保留到你删除或卸载应用为止（设备备份行为除外）。本应用不声称对数据进行应用级加密。请保护设备和备份。可在系统设置中更改位置和通知权限。政策更新后会在使用前展示新版本。''',
  };

  static const _terms = {
    'en': '''DATSURŌ Terms of Use · Version 2

DATSURŌ is a personal diary and habit encouragement app, not a medical, emergency, navigation, or safety service. Stamps and milestones are motivational features and are not proof of travel or activity.

Automatic escape detection depends on location permission, device settings, and location accuracy. It may miss an exit, record one late, or be interrupted when the app is force-stopped or the operating system restricts background activity. Do not rely on it for safety, attendance, billing, or legal evidence. You can turn tracking off at any time.

You are responsible for the accuracy of information you enter, having rights to photos and notes, and protecting your device and backups. The app stores data locally; exported archives may include sensitive diary content and home coordinates. Keep them private and import only backups you trust.

The app is provided as available. We do not guarantee uninterrupted operation, precise location detection, or recovery of data that was not backed up. Features and these terms may change in a future version. By accepting, you agree to use the app lawfully and understand its location limitations.''',
    'ja': '''脱籠 利用規約 · 第2版

脱籠は日記と習慣づくりを応援する個人向けアプリです。医療、緊急対応、ナビ、安全確認サービスではありません。スタンプやマイルストーンは励ましの機能であり、移動や活動の証明にはなりません。

自動外出検出は位置情報の許可、端末設定、測位精度に依存します。外出を検出できない、遅れて記録する、強制終了やOSのバックグラウンド制限で中断する場合があります。安全、出席、料金計算、法的証拠に使わないでください。追跡はいつでも停止できます。

入力内容の正確性、写真・文章を利用する権利、端末とバックアップの保護は利用者の責任です。書き出したファイルには日記や自宅座標などの機微な情報が含まれる場合があります。安全に保管し、信頼できるバックアップのみ読み込んでください。

本アプリは提供可能な範囲で動作します。継続稼働、正確な位置検出、バックアップのないデータの復旧を保証しません。機能や規約は将来変更されることがあります。同意することで、法令に従って利用し、位置情報機能の限界を理解したものとします。''',
    'ko': '''脱籠 이용약관 · 버전 2

脱籠은 개인 일기 및 습관 형성을 돕는 앱입니다. 의료, 긴급 구조, 내비게이션 또는 안전 서비스가 아닙니다. 스탬프와 목표는 동기 부여 기능이며 이동이나 활동의 증거가 아닙니다.

자동 외출 감지는 위치 권한, 기기 설정 및 정확도에 따라 달라집니다. 외출을 놓치거나 늦게 기록할 수 있고 앱 강제 종료나 운영체제의 백그라운드 제한으로 중단될 수 있습니다. 안전, 출석, 요금 청구 또는 법적 증거로 사용하지 마세요. 언제든 추적을 끌 수 있습니다.

입력 정보의 정확성, 사진과 글에 대한 권리, 기기와 백업 보호는 사용자의 책임입니다. 내보낸 파일에는 민감한 일기와 집 좌표가 포함될 수 있습니다. 안전하게 보관하고 신뢰할 수 있는 백업만 가져오세요.

앱은 제공 가능한 상태로 제공됩니다. 중단 없는 작동, 정확한 위치 감지 또는 백업하지 않은 데이터 복구를 보장하지 않습니다. 기능과 약관은 향후 변경될 수 있습니다. 동의하면 법률을 준수해 앱을 사용하고 위치 기능의 한계를 이해하는 데 동의합니다.''',
    'zh': '''脱籠 使用条款 · 第2版

脱籠是个人日记和习惯鼓励应用，不是医疗、紧急救援、导航或安全服务。印章和里程碑用于鼓励，不是旅行或活动证明。

自动外出检测取决于位置权限、设备设置和定位精度。它可能漏记、延迟记录，也可能因强制停止或操作系统限制后台活动而中断。请勿将其用于安全、考勤、计费或法律证据。你可以随时关闭追踪。

你负责确保输入信息准确、拥有照片和文字的使用权，并保护设备及备份。导出的文件可能包含敏感日记内容和家的坐标。请妥善保管，并仅导入可信备份。

本应用按可用状态提供，不保证持续运行、精确定位或恢复未备份数据。功能和条款可能在后续版本中变更。接受条款即表示你同意合法使用，并理解位置功能的限制。''',
  };

  static String privacyPolicy(String language) =>
      _privacy[language] ?? _privacy['en']!;
  static String termsOfUse(String language) =>
      _terms[language] ?? _terms['en']!;
}
