import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'dados.dart';

/// Avisos de validade no celular, mesmo com o app fechado.
final _plugin = FlutterLocalNotificationsPlugin();

const _detalhes = NotificationDetails(
  android: AndroidNotificationDetails(
    'validade',
    'Validade dos alimentos',
    channelDescription: 'Avisa um dia antes de um alimento vencer',
    icon: 'ic_notificacao',
  ),
  iOS: DarwinNotificationDetails(),
);

Future<void> iniciarAvisos() async {
  await _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('ic_notificacao'),
      // A permissão só é pedida quando houver o primeiro aviso a agendar.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
  );
  dados.aoMudarValidade = (a, validade) => agendarAviso(
    a,
    validade,
  ).catchError((Object e) => debugPrint('aviso de validade falhou: $e'));
}

/// Quando avisar: 9h da véspera ("vence amanhã"); se já passou, 9h do dia
/// ("vence hoje"); se também já passou, não avisa.
(DateTime, String)? quandoAvisar(DateTime validade, DateTime agora) {
  final dia = DateTime(validade.year, validade.month, validade.day, 9);
  for (final (momento, texto) in [
    (DateTime(dia.year, dia.month, dia.day - 1, 9), 'vence amanhã'),
    (dia, 'vence hoje'),
  ]) {
    if (momento.isAfter(agora)) return (momento, texto);
  }
  return null;
}

Future<void> agendarAviso(Alimento a, DateTime? validade) async {
  await _plugin.cancel(id: a.id);
  final quando = validade == null
      ? null
      : quandoAvisar(validade, dados.agora());
  if (quando == null) return;
  final (momento, texto) = quando;
  await _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();
  await _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >()
      ?.requestPermissions(alert: true, sound: true);
  await _plugin.zonedSchedule(
    id: a.id,
    // Instante absoluto em UTC: dispensa a base de fusos horários.
    scheduledDate: tz.TZDateTime.from(momento.toUtc(), tz.UTC),
    notificationDetails: _detalhes,
    // Sem horário exato: não exige a permissão de alarmes do Android 14.
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    title: '${a.nomeCurto} $texto',
    body: 'Que tal usar numa receita hoje? Abra o NutriCasa para ver ideias.',
  );
}
