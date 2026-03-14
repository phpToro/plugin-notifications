<?php

namespace PhpToro\Plugins\Notifications;

class Notifications
{
    public static function requestPermission(): array
    {
        $json = phptoro_native_call('notifications', 'requestPermission', '{}');
        return json_decode($json, true) ?? [];
    }

    public static function checkPermission(): string
    {
        $json = phptoro_native_call('notifications', 'checkPermission', '{}');
        $result = json_decode($json, true) ?? [];
        return $result['status'] ?? 'unknown';
    }

    public static function schedule(string $title, string $body, array $options = []): string
    {
        $args = array_merge($options, ['title' => $title, 'body' => $body]);
        $json = phptoro_native_call('notifications', 'schedule', json_encode($args));
        $result = json_decode($json, true) ?? [];
        return $result['id'] ?? '';
    }

    public static function cancel(string $id): bool
    {
        $json = phptoro_native_call('notifications', 'cancel', json_encode(['id' => $id]));
        return json_decode($json, true) === true;
    }

    public static function cancelAll(): bool
    {
        $json = phptoro_native_call('notifications', 'cancelAll', '{}');
        return json_decode($json, true) === true;
    }

    public static function setBadge(int $count): bool
    {
        $json = phptoro_native_call('notifications', 'setBadge', json_encode(['count' => $count]));
        return json_decode($json, true) === true;
    }
}
