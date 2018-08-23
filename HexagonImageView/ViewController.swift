//
//  ViewController.swift
//  HexagonImageView
//
//  Created by LTT-ThanhLH on 12/30/17.
//  Copyright © 2017 LifetimeTech. All rights reserved.
//

import UIKit

enum Shape {
    case triangle
    case square
    case pentagon
    case hexagon
    case polygon(Int)
    
    var side: Int {
        switch self {
        case .triangle:
            return 3
        case .square:
            return 4
        case .pentagon:
            return 5
        case .hexagon:
            return 6
        case .polygon(let value):
            // octagon, nonagon, decagon...
            return value
        }
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var polygon1: UIView!
    @IBOutlet weak var polygon2: UIView!
    @IBOutlet weak var polygon3: UIView!
    @IBOutlet weak var polygon4: UIView!
    @IBOutlet weak var polygon5: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.configureLayerForHexagon(rotation: CGFloat(Double.pi / 6))
        setupPolygonView(polygon1)
        setupPolygonView(polygon2, shape: Shape.polygon(5), rotation: CGFloat(Double.pi / 5))
        setupPolygonView(polygon3, shape: Shape.polygon(5))
        setupPolygonView(polygon4, shape: Shape.triangle)
        setupPolygonView(polygon5, shape: Shape.triangle, rotation: CGFloat(Double.pi / 6))
    }
    
    func setupPolygonView(_ view: UIView, shape: Shape = .hexagon, radius: CGFloat = 5, rotation: CGFloat = 0) {
        let lineWidth: CGFloat = 5
        let path = UIBezierPath(polygonIn: view.bounds, sides: shape.side, lineWidth: lineWidth, cornerRadius: radius)
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.lineWidth = lineWidth
        mask.strokeColor = UIColor.clear.cgColor
        mask.fillColor = UIColor.white.cgColor
        view.layer.mask = mask
        
        let border = CAShapeLayer()
        border.path = path.cgPath
        border.lineWidth = lineWidth
        border.strokeColor = UIColor.white.cgColor
        border.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(border)
        
        view.transform = CGAffineTransform(rotationAngle: rotation)
    }
}

extension UIView {
    func configureLayerForHexagon(rotation: CGFloat = 0) {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.frame = bounds
        
        let width = bounds.width
        let height = bounds.height
        let hPadding = width * 1 / 8 / 2
        
        UIGraphicsBeginImageContext(bounds.size)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width - hPadding, y: height / 4))
        path.addLine(to: CGPoint(x: width - hPadding, y: height * 3 / 4))
        path.addLine(to: CGPoint(x: width / 2, y: height))
        path.addLine(to: CGPoint(x: hPadding, y: height * 3 / 4))
        path.addLine(to: CGPoint(x: hPadding, y: height / 4))
        
        path.close()
        path.fill()
        maskLayer.path = path.cgPath
        UIGraphicsEndImageContext()
        layer.mask = maskLayer
        transform = CGAffineTransform(rotationAngle: rotation)
    }
}

extension UIBezierPath {
    
    /// Create UIBezierPath for regular polygon with rounded corners
    ///
    /// - parameter rect:            The CGRect of the square in which the path should be created.
    /// - parameter sides:           How many sides to the polygon (e.g. 6=hexagon; 8=octagon, etc.).
    /// - parameter lineWidth:       The width of the stroke around the polygon. The polygon will be inset such that the stroke stays within the above square. Default value 1.
    /// - parameter cornerRadius:    The radius to be applied when rounding the corners. Default value 0.
    
    convenience init(polygonIn rect: CGRect, sides: Int, lineWidth: CGFloat = 1, cornerRadius: CGFloat = 0) {
        self.init()
        let theta = 2 * CGFloat.pi / CGFloat(sides) // how much to turn at every corner
        let offset = cornerRadius * tan(theta / 2)  // offset from which to start rounding corners
        let squareWidth = min(rect.size.width, rect.size.height)    // width of the square
        
        // calculate the length of the sides of the polygon
        var length = squareWidth - lineWidth
        
        // if not dealing with polygon which will be square with all sides ...
        if sides % 4 != 0 {
            // ... offset it inside a circle inside the square
            length = length * cos(theta / 2) + offset / 2
        }
        let sideLength = length * tan(theta / 2)
        
        // start drawing at `point` in lower right corner, but center it
        var point = CGPoint(x: rect.origin.x + rect.size.width / 2 + sideLength / 2 - offset, y: rect.origin.y + rect.size.height / 2 + length / 2)
        var angle = CGFloat.pi
        move(to: point)
        
        // draw the sides and rounded corners of the polygon
        for _ in 0 ..< sides {
            point = CGPoint(x: point.x + (sideLength - offset * 2) * cos(angle), y: point.y + (sideLength - offset * 2) * sin(angle))
            addLine(to: point)
            
            let center = CGPoint(x: point.x + cornerRadius * cos(angle + .pi / 2), y: point.y + cornerRadius * sin(angle + .pi / 2))
            addArc(withCenter: center, radius: cornerRadius, startAngle: angle - .pi / 2, endAngle: angle + theta - .pi / 2, clockwise: true)
            
            point = currentPoint
            angle += theta
        }
        close()
        self.lineWidth = lineWidth // in case we're going to use CoreGraphics to stroke path, rather than CAShapeLayer
        lineJoinStyle = .round
    }
}
