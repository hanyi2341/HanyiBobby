//
//  StickMan 2.swift
//  Bobby
//
//  Created by Hanyi on 2/8/25.
//
import SwiftUI

/// Basic stickman
struct StickMan: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()

        // Head
        let headRadius: CGFloat = 30
        let headCentre = CGPoint(x: rect.midX, y: rect.minY + headRadius)
        p.addEllipse(in: CGRect(
            x: headCentre.x - headRadius,
            y: headCentre.y - headRadius,
            width: headRadius * 2,
            height: headRadius * 2))

        // Body line
        let neck = CGPoint(x: headCentre.x, y: headCentre.y + headRadius)
        let hip = CGPoint(x: headCentre.x, y: neck.y + 90)
        p.move(to: neck); p.addLine(to: hip)

        // Arms
        let leftHand  = CGPoint(x: neck.x - 60, y: neck.y + 40)
        let rightHand = CGPoint(x: neck.x + 60, y: neck.y + 40)
        p.move(to: CGPoint(x: neck.x, y: neck.y + 30))
        p.addLine(to: leftHand)
        p.move(to: CGPoint(x: neck.x, y: neck.y + 30))
        p.addLine(to: rightHand)

        // Legs
        let leftFoot  = CGPoint(x: hip.x - 45, y: hip.y + 90)
        let rightFoot = CGPoint(x: hip.x + 45, y: hip.y + 90)
        p.move(to: hip); p.addLine(to: leftFoot)
        p.move(to: hip); p.addLine(to: rightFoot)

        return p
    }
}
