// Generated by CoffeeScript 1.7.1
(function() {
  this.tageswoche = this.tageswoche || {};

  tageswoche.curve = (function() {
    var percentRegex;
    percentRegex = /(\d+)%/;
    return {
      curve: function(start, end, curvedness, curvePosition, direction) {
        var controlPoint, path;
        if (curvedness == null) {
          curvedness = 0;
        }
        if (curvePosition == null) {
          curvePosition = 0.5;
        }
        controlPoint = this.bezierControlPoint(start, end, curvedness, curvePosition, direction);
        path = "M" + [start.x, start.y];
        return path += "C" + [controlPoint.x, controlPoint.y, end.x, end.y, end.x, end.y];
      },
      wavy: function(start, end, curvedness) {
        var controlPoint1, controlPoint2, path;
        controlPoint1 = this.bezierControlPoint(start, end, curvedness, 0.35, "right");
        controlPoint2 = this.bezierControlPoint(start, end, curvedness, 0.65, "left");
        path = "M" + [start.x, start.y];
        return path += "C" + [controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, end.x, end.y];
      },
      arrow: function(base, tip, pointyness) {
        var path, pointA, pointB, size;
        if (pointyness == null) {
          pointyness = 0.5;
        }
        size = this.distance(base, tip) * pointyness;
        pointA = this.bezierControlPoint(base, tip, size, 0, "right");
        pointB = this.bezierControlPoint(base, tip, size, 0, "left");
        path = "M" + [pointB.x, pointB.y];
        path += "L" + [tip.x, tip.y];
        return path += "L" + [pointA.x, pointA.y];
      },
      line: function(start, end) {
        return "M" + [start.x, start.y] + "L" + [end.x, end.y];
      },
      distance: function(start, end) {
        var deltaX, deltaY;
        deltaX = end.x - start.x;
        deltaY = end.y - start.y;
        return Math.sqrt((deltaX * deltaX) + (deltaY * deltaY));
      },
      intermediatePoint: function(start, end, fraction) {
        var deltaX, deltaY;
        deltaX = end.x - start.x;
        deltaY = end.y - start.y;
        return {
          x: start.x + (deltaX * fraction),
          y: start.y + (deltaY * fraction)
        };
      },
      bezierControlPoint: function(start, end, curvedness, curvePosition, direction) {
        var angularVector, intermediatePoint, normVector, percent;
        if (direction == null) {
          direction = "right";
        }
        if (percent = this.percent(curvedness)) {
          curvedness = this.distance(start, end) * percent;
        }
        intermediatePoint = this.intermediatePoint(start, end, curvePosition);
        normVector = this.normVector(start, end);
        angularVector = direction === "left" ? this.rotateVectorClockwise(normVector) : this.rotateVectorCounterClockwise(normVector);
        return this.add(intermediatePoint, this.multiply(angularVector, curvedness));
      },
      percent: function(percent) {
        var result;
        result = percentRegex.exec(percent);
        if (result) {
          return result[1] / 100;
        } else {
          return void 0;
        }
      },
      multiply: function(vector, multiplicator) {
        return {
          x: vector.x * multiplicator,
          y: vector.y * multiplicator
        };
      },
      add: function(vector1, vector2) {
        return {
          x: vector1.x + vector2.x,
          y: vector1.y + vector2.y
        };
      },
      normVector: function(start, end) {
        var deltaX, deltaY, distance, normX, normY;
        deltaX = end.x - start.x;
        deltaY = end.y - start.y;
        distance = Math.sqrt((deltaX * deltaX) + (deltaY * deltaY));
        normX = deltaX / distance;
        normY = deltaY / distance;
        return {
          x: normX,
          y: normY
        };
      },
      rotateVectorClockwise: function(vector) {
        return {
          x: vector.y,
          y: -vector.x
        };
      },
      rotateVectorCounterClockwise: function(vector) {
        return {
          x: -vector.y,
          y: vector.x
        };
      },
      delta: function(start, end) {
        return {
          x: end.x - start.x,
          y: end.y - start.y
        };
      },
      slope: function(start, end) {
        var delta;
        delta = this.delta(start, end);
        return delta.y / delta.x;
      },
      inverseSlope: function(start, end) {
        return -1 / this.slope(start, end);
      }
    };
  })();

}).call(this);
