# 🎨 SideSketch

**SideSketch** est une solution permettant d'utiliser un iPad comme tablette graphique pour macOS. Ce projet utilise une architecture client-serveur TCP pour transmettre les données de l'Apple Pencil avec une latence minimale.

---

##  Architecture
Le système est divisé en deux applications communiquant par le protocole TCP (Port 12345).

* **SideSketchiPad (Client) :** Capture les touches (`touchesMoved`) et les données de pression de l'Apple Pencil.
* **SideSketchMac (Serveur) :** Reçoit les paquets, décode le JSON et injecte les événements de souris via CoreGraphics.

---

## Configuration du projet Mac (`SideSketchMac`)

### 1. Frameworks requis
Les bibliothèques suivantes sont utilisées nativement :
* `Network` : Gestion des sockets TCP (NWListener).
* `CoreGraphics` : Injection des mouvements du curseur.
* `AppKit` : Gestion de l'affichage et des écrans.

### 2. App Sandbox 
Pour que le serveur puisse fonctionner, vous devez activer les droits réseau dans Xcode :
* **Incoming Connections (Server)** 
* **Outgoing Connections (Client)** 

### 3. Permissions d'Accessibilité 
L'injection de curseur via `CGEvent` nécessite une autorisation système :
1.  Lancer l'application.
2.  Ouvrir **Réglages Système > Confidentialité & Sécurité > Accessibilité**.
3.  Ajouter **SideSketchMac.app** et activer le bouton.
> *Note : Sans cette étape, le curseur restera immobile malgré la réception des paquets.*

---

## Configuration du projet iPad (`SideSketchiPad`)

* **Réseau Local** : Pour autoriser la découverte du Mac, ajoutez ceci à votre `Info.plist` :
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>SideSketch utilise le réseau local pour se connecter à votre Mac.</string>
