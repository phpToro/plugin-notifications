phpToro.notifications = {
    requestPermission: function() {
        return phpToro.nativeCall('notifications', 'requestPermission', {});
    },
    checkPermission: function() {
        return phpToro.nativeCall('notifications', 'checkPermission', {});
    },
    schedule: function(options) {
        return phpToro.nativeCall('notifications', 'schedule', options);
    },
    cancel: function(id) {
        return phpToro.nativeCall('notifications', 'cancel', { id: id });
    },
    cancelAll: function() {
        return phpToro.nativeCall('notifications', 'cancelAll', {});
    },
    setBadge: function(count) {
        return phpToro.nativeCall('notifications', 'setBadge', { count: count });
    }
};
