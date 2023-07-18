(function () {
    var fn_init = function (settings) {
        var $ = jQuery;
        var $divOptions = $('#wpfront-notification-bar-options');

        $divOptions.on('change', '.pages-selection input[type="checkbox"]', function () {
            var $this = $(this);
            var $input = $this.parent().parent().parent().prev();
            var $text = $input.val();

            if ($this.prop('checked')) {
                $text += ',' + $this.val();
            } else {
                $text = (',' + $text + ',').replace(',' + $this.val() + ',', ',');
            }

            $text = $text.replace(/(^[,\s]+)|([,\s]+$)/g, '');
            $input.val($text);
        });

        $divOptions.on('change', '.roles-selection input[type="checkbox"]', function () {
            var values = [];
            var div = $(this).parent().parent().parent();
            div.find('input:checked').each(function (i, e) {
                values.push($(e).val());
            });
            div.children(":first").val(JSON.stringify(values));
        });

        minutestohours();

        if ($("#date-none").is(":checked") === true) {
            $('.start-end-date').hide();
            $('.schedule-date').hide();
        } else if ($("#start-end-date").is(":checked") === true) {
            $('.start-end-date').show();
            $('.schedule-date').hide();
        } else {
            $('.start-end-date').hide();
            $('.schedule-date').show();
        }

        $divOptions.on('click', '#start-end-date', function () {
            $('.start-end-date').show();
            $('.schedule-date').hide();
        });
        $divOptions.on('click', '#schedule-date', function () {
            $('.start-end-date').hide();
            $('.schedule-date').show();
        });
        $divOptions.on('click', '#date-none', function () {
            $('.start-end-date').hide();
            $('.schedule-date').hide();
        });

        function schedule() {
            var cronminutes = [];
            var cronhours = [];
            var cronmday = [];
            var cronmon = [];
            var cronwday = [];
            var schedule_date = $('input[name="wpfront-notification-bar-options[schedule_start_date]"]').val();
            var schedule_time = $('input[name="wpfront-notification-bar-options[schedule_start_time]"]').val();
            var schedule_duration = $('input[name="wpfront-notification-bar-options[schedule_duration]"]').val();

            if ('hour' == $('input[name="wpfront-notification-bar-options[schedule]"]:checked').val()) {
                cronminutes.push($('select[name="hour_cron_minutes"]').val());
                cronhours.push('*');
                cronmday.push('*');
                cronmon.push('*');
                cronwday.push('*');
            }

            if ('day' == $('input[name="wpfront-notification-bar-options[schedule]"]:checked').val()) {
                cronminutes.push($('select[name="day_cron_minutes"]').val());
                cronhours.push($('select[name="day_cron_hours"]').val());
                cronmday.push('*');
                cronmon.push('*');
                cronwday.push('*');
            }

            if ('week' == $('input[name="wpfront-notification-bar-options[schedule]"]:checked').val()) {
                cronminutes.push($('select[name="weekly_cron_minutes"]').val());
                cronhours.push($('select[name="weekly_cron_hours"]').val());
                cronmday.push('*');
                cronmon.push('*');
                cronwday.push($('select[name="weekly_cron_days"]').val());
            }

            if ('mon' == $('input[name="wpfront-notification-bar-options[schedule]"]:checked').val()) {
                cronminutes.push($('select[name="monthly_cron_minutes"]').val());
                cronhours.push($('select[name="monthly_cron_hours"]').val());
                cronmday.push($('select[name="monthly_cron_days"]').val());
                cronmon.push('*');
                cronwday.push('*');
            }

            var data = {
                action: 'notification_bar_cron_text',
                cronminutes: cronminutes,
                cronhours: cronhours,
                cronmday: cronmday,
                cronmon: cronmon,
                cronwday: cronwday,
                schedulestartdate: schedule_date,
                schedulestarttime: schedule_time,
                scheduleduration: schedule_duration
            };

            $.post(ajaxurl, data, function (response) {
                $('#notification-bar-schedule').replaceWith(response);
            });

        }

        $divOptions.on('change', '[name="wpfront-notification-bar-options[schedule]"], select[name="hour_cron_minutes"], select[name="day_cron_minutes"], select[name="day_cron_hours"], select[name="weekly_cron_days"], select[name="weekly_cron_minutes"], select[name="weekly_cron_hours"], select[name="monthly_cron_days"], select[name="monthly_cron_hours"], select[name="monthly_cron_minutes"], input[name="wpfront-notification-bar-options[schedule_start_date]"], input[name="wpfront-notification-bar-options[schedule_start_time]"], input[name="wpfront-notification-bar-options[schedule_duration]"] ', function () {
            schedule();
        });

        $divOptions.on('focusout', '[name="wpfront-notification-bar-options[schedule_duration]"]', function () {
            minutestohours();
        });

        function minutestohours() {
            var duration = parseInt($('input[name="wpfront-notification-bar-options[schedule_duration]"]').val());
            if (duration > 60) {
                var hours = (duration / 60);
                var comp_hours = Math.floor(hours);
                var minutes = (hours - comp_hours) * 60;
                var comp_minutes = Math.round(minutes);
                var hours_minutes;
                if (comp_minutes > 0) {
                    hours_minutes = settings.x_hours_minutes.replace("%1$d", comp_hours).replace("%2$d", comp_minutes);
                } else {
                    hours_minutes = settings.x_hours.replace("%1$d", comp_hours);
                }
                $('#schedule_duration').replaceWith('<span id="schedule_duration" class="description">= ' + hours_minutes + '</span>');
            } else {
                $('#schedule_duration').replaceWith('<span id="schedule_duration" class="description"></span>');
            }
        }


        $divOptions.find('input.date').datepicker({
            'dateFormat': 'yy-mm-dd'
        });

        $divOptions.find('input.time').timepicker({
            'timeFormat': 'h:i a'
        });

        $divOptions.on('change', '#chk_button_action_url_noopener', function () {
            $('#txt_button_action_url_noopener').val($(this).prop('checked') ? 1 : 0);
        });

        function setColorPicker(div) {
            if (div.ColorPicker) {
                div.ColorPicker({
                    color: div.attr('color'),
                    onShow: function (colpkr) {
                        $(colpkr).fadeIn(500);
                        return false;
                    }, onHide: function (colpkr) {
                        $(colpkr).fadeOut(500);
                        return false;
                    },
                    onChange: function (hsb, hex, rgb) {
                        div.css('backgroundColor', '#' + hex);
                        div.next().val('#' + hex);
                    }
                }).css('backgroundColor', div.attr('color'));
            }
        }

        $divOptions.find(".color-selector").each(function (i, e) {
            setColorPicker($(e));
        });

    };

    window.init_wpfront_notifiction_bar_options = function (settings) {
        var $ = jQuery;
        
        if(document.readyState === "complete") {
            fn_init(settings);
        } else {
            $(function(){
                fn_init(settings);
            });
        }

        var mediaLibrary = null;

        $('#wpfront-notification-bar-options').on('click', '#media-library-button', function () {
            if (mediaLibrary === null) {
                mediaLibrary = wp.media.frames.file_frame = wp.media({
                    title: settings.choose_image,
                    multiple: false,
                    button: {
                        text: settings.select_image
                    }
                }).on('select', function () {
                    var obj = mediaLibrary.state().get('selection').first().toJSON();

                    $('#reopen-button-image-url').val(obj.url);
                });
            }

            mediaLibrary.open();
            return false;
        });
    };
})();