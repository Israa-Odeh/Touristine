import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> initializeNotifications() async {
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelGroupKey: "touristine_channel_group",
      channelKey: "touristine_channel",
      channelName: "Touristine Notification",
      channelDescription: "Touristine notifications channel",
    )
  ], channelGroups: [
    NotificationChannelGroup(
        channelGroupKey: "touristine_channel_group",
        channelGroupName: "Touristine Group")
  ]);

  bool isAllowedToSendNotification =
      await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
}
