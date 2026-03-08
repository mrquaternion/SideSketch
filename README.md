#SideSketch

**SideSketch** est une solution permettant d'utiliser un iPad comme tablette graphique pour macOS. Ce projet utilise une architecture client-serveur TCP pour transmettre les données de l'Apple Pencil avec une latence minimale.

---

##  Architecture
Le système est divisé en deux applications communiquant par le protocole TCP (Port 12345).

* **SideSketchiPad (Client) :** Capture les gestes et les données de pression de l'Apple Pencil.
* **SideSketchMac (Serveur) :** Reçoit les paquets, décode le JSON et injecte les événements de souris via CoreGraphics.

---

## Configuration du projet Mac (`SideSketchMac`)

### 1. App Sandbox 
Pour que le serveur puisse fonctionner, vous devez activer les droits réseau dans Xcode :
* **Incoming Connections (Server)** 
* **Outgoing Connections (Client)** 

### 2. Permissions d'Accessibilité 
L'injection de curseur via `CGEvent` nécessite une autorisation système :
1.  Lancer l'application.
2.  Ouvrir **Réglages Système > Confidentialité & Sécurité > Accessibilité**.
3.  Ajouter **SideSketchMac.app** et activer le bouton.

---

## TODO

### Expérience Utilisateur (UX) & Interface

* Améliorer la gestion des états du stylet (Hover vs. Draw) : Actuellement en position relative et toujours actif. Il faut différencier le déplacement (survol/hover) du tracé. Action : Implémenter une méthode intuitive pour activer/désactiver la pression (ex. détection de l'approche du stylet, ou gestion du double-tap) pour permettre de lever le crayon sans dessiner.

* Développer une barre d'outils iPad synchronisée : Ajouter un menu sur l'interface de l'iPad permettant de sélectionner rapidement un outil (stylet, gomme, espace, etc.). Assurer une communication bidirectionnelle pour que l'outil sélectionné sur l'iPad reflète l'état du whiteboard/interface côté Mac, et vice-versa.

### Réseau & Connectivité

Simplifier le processus de connexion (Auto-discovery) : Remplacer la saisie manuelle de l'adresse IP TCP. Intégrer un protocole de découverte réseau local (comme Bonjour ou mDNS) pour permettre à l'iPad de détecter et de se connecter automatiquement au Mac en un clic, tout en conservant la stabilité de la connexion TCP sous-jacente.

### Nouvelles Fonctionnalités

* Intégrer la saisie de texte : Ajouter le support d'un clavier (virtuel sur l'iPad) pour permettre l'insertion de texte sur le whiteboard.

* Ajouter le support multi-écrans : Gérer les configurations à plusieurs moniteurs côté Mac pour que l'utilisateur puisse cartographier ou déplacer l'espace de travail de l'iPad vers l'écran de son choix.
