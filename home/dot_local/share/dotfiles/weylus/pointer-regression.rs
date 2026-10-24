
#[cfg(test)]
mod dotfiles_regression {
    use super::MessageInbound;

    #[test]
    fn fractional_pointer_movements() {
        // iPadOS 26 reports fractional movement even though the absolute
        // position, pressure and tilt remain the inputs Weylus actually uses.
        for pointer_type in ["pen", "touch", "mouse"] {
            for (movement_x, movement_y) in [(-3.5, 2.25), (0.0, -0.5), (3.0, 2.0)] {
                let message = serde_json::json!({
                    "PointerEvent": {
                        "event_type": "pointermove", "pointer_id": 1,
                        "timestamp": 8460000, "is_primary": true,
                        "pointer_type": pointer_type, "button": 0, "buttons": 1,
                        "x": 0.75, "y": 0.25,
                        "movement_x": movement_x, "movement_y": movement_y,
                        "pressure": 0.5, "tilt_x": -15, "tilt_y": 20,
                        "width": 0.001, "height": 0.001, "twist": 0
                    }
                });
                let parsed = serde_json::from_value::<MessageInbound>(message)
                    .expect("fractional movement must not reject pointer input");
                match parsed {
                    MessageInbound::PointerEvent(event) => {
                        assert_eq!((event.x, event.y), (0.75, 0.25));
                        assert_eq!(event.pressure, 0.5);
                        assert_eq!((event.tilt_x, event.tilt_y), (-15, 20));
                    }
                    other => panic!("expected pointer input, got {other:?}"),
                }
            }
        }
    }
}
