/*
 * =====================================================================
 * Part of the AsteroidOS Custom Software Suite
 * Architecture, Engine & UI Engineering by Gemini (Google)
 * Co-Developed & Tested on-device by DarkwingDuck13
 *
 * Platform: AsteroidOS (Linux / Qt6 / OpenEmbedded / TicWatch Pro)
 * =====================================================================
 */

import QtQuick
import org.asteroid.controls

FlatMesh {
    anchors.fill: parent
    centerColor: "#103d52"  // AsteroidOS Media Teal Center
    outerColor: "#030a0e"   // Deep Black-Teal Vignette Edge
    animated: false         // 0% CPU impact, static low-poly crystal
}
