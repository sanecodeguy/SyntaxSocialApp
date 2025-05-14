import QtQuick 2.15

Item {
    id: root
    width: 50
    height: 50

    // Public API - call this function to start the animation at specified position
    function like(x, y) {
        var heart = heartComponent.createObject(root.parent, {
            "x": x - width/2,
            "y": y - height/2
        });
        heart.startAnimation();
    }

    // Private implementation
    Component {
        id: heartComponent
        
        Item {
            id: heartContainer
            width: 50
            height: 50
            
            property real targetX: (Math.random() - 0.5) * 100
            property real targetY: -100
            
            // Custom animation properties
            property real animScale: 0.5
            property real animRotation: (Math.random() - 0.5) * 30
            property real animOpacity: 0
            property real animXProgress: 0
            property real animYProgress: 0
            
            // Heart shape
            Canvas {
                id: heartCanvas
                anchors.fill: parent
                
                onPaint: {
                    var ctx = getContext("2d");
                    var centerX = width / 2;
                    var centerY = height / 2;
                    
                    var gradient = ctx.createLinearGradient(0, 0, width, height);
                    gradient.addColorStop(0.2, "red");
                    gradient.addColorStop(1, "purple");
                    
                    ctx.fillStyle = gradient;
                    ctx.strokeStyle = "transparent";
                    ctx.lineWidth = 0;
                    
                    ctx.beginPath();
                    ctx.moveTo(centerX, height * 0.35);
                    ctx.bezierCurveTo(
                        width * 0.2, height * 0.1,
                        -width * 0.25, height * 0.6,
                        centerX, height
                    );
                    ctx.bezierCurveTo(
                        width * 1.25, height * 0.6,
                        width * 0.8, height * 0.1,
                        centerX, height * 0.35
                    );
                    ctx.closePath();
                    ctx.fill();
                }
            }
            
            // Transformations
            transform: [
                Scale { 
                    xScale: animScale
                    yScale: animScale
                },
                Rotation {
                    angle: animRotation
                    origin.x: width/2
                    origin.y: height/2
                },
                Translate {
                    x: animXProgress * targetX
                    y: animYProgress * targetY
                }
            ]
            
            opacity: animOpacity
            
            // Animation sequence
            SequentialAnimation {
                id: mainAnimation
                running: false
                
                ParallelAnimation {
                    NumberAnimation {
                        target: heartContainer
                        property: "animScale"
                        from: 0.5
                        to: 1.0
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                    
                    NumberAnimation {
                        target: heartContainer
                        property: "animRotation"
                        to: 0
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                    
                    NumberAnimation {
                        target: heartContainer
                        property: "animOpacity"
                        from: 0
                        to: 1
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }
                
                ParallelAnimation {
                    NumberAnimation {
                        target: heartContainer
                        property: "animScale"
                        from: 1.0
                        to: 1.5
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                    
                    NumberAnimation {
                        target: heartContainer
                        property: "animOpacity"
                        from: 1
                        to: 0
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                    
                    NumberAnimation {
                        target: heartContainer
                        property: "animXProgress"
                        from: 0
                        to: 1
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                    
                    NumberAnimation {
                        target: heartContainer
                        property: "animYProgress"
                        from: 0
                        to: 1
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }
                
                ScriptAction {
                    script: heartContainer.destroy()
                }
            }
            
            function startAnimation() {
                mainAnimation.start();
            }
            
            Component.onCompleted: {
                heartCanvas.requestPaint();
            }
        }
    }
}