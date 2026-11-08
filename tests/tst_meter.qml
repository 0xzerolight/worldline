import QtQuick
import QtTest
import "../package/contents/ui"

Item {
    width: 800
    height: 240

    Meter {
        id: meter
        anchors.fill: parent
        scrambleMs: 200
        lockStepMs: 20
        tickMs: 10
    }

    SignalSpy {
        id: settledSpy
        target: meter
        signalName: "settled"
    }

    TestCase {
        name: "Meter"
        when: windowShown

        function init() {
            settledSpy.clear();
        }

        function test_shift_scrambles_then_settles_on_target() {
            meter.shiftTo("0.571024");
            verify(meter.busy);
            compare(meter.target, "0.571024");
            settledSpy.wait(3000);
            compare(settledSpy.count, 1);
            verify(!meter.busy);
            compare(meter.value, "0.571024");
            compare(meter.shown, [0, -1, 5, 7, 1, 0, 2, 4]);
        }

        function test_retarget_during_scramble() {
            meter.shiftTo("0.337187");
            meter.shiftTo("1.130205");
            settledSpy.wait(3000);
            compare(settledSpy.count, 1);
            compare(meter.value, "1.130205");
        }

        function test_idle_display_follows_value() {
            meter.value = "1.382733";
            compare(meter.shown, [1, -1, 3, 8, 2, 7, 3, 3]);
        }

        function test_clock_value_puts_dots_on_their_own_tubes() {
            meter.value = "12.34.56";
            compare(meter.shown, [1, 2, -1, 3, 4, -1, 5, 6]);
        }

        function test_set_when_idle_shows_at_once() {
            meter.set("0.409431");
            verify(!meter.busy);
            compare(meter.value, "0.409431");
            compare(meter.shown, [0, -1, 4, 0, 9, 4, 3, 1]);
        }

        function test_set_during_scramble_settles_on_it() {
            meter.shiftTo("09.15.40");
            meter.set("09.15.41");
            verify(meter.busy);
            settledSpy.wait(3000);
            compare(settledSpy.count, 1);
            compare(meter.value, "09.15.41");
            compare(meter.shown, [0, 9, -1, 1, 5, -1, 4, 1]);
        }

        function test_layout_fits_width() {
            verify(meter.tubeW * 8 <= meter.width);
            verify(meter.tubeH <= meter.height);
            compare(meter.widthPerHeight, (8 + 7 * meter.gapRatio) / meter.aspect);
        }
    }
}
