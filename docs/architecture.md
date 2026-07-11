# Architecture STUdio

## Vue d'ensemble

**STUdio** est une application Java multi-modules permettant de créer et transférer des packs d'histoires pour la Fabrique à Histoires Lunii. Architecture modulaire Maven avec 5 modules principaux.

**Version actuelle :** 0.4.3-SNAPSHOT  
**Licence :** Mozilla Public License 2.0  
**Java :** 11 (sauf agent/metadata en Java 8)

---

## Structure des Modules

### 1. core (`studio-core`)

Module central de traitement des packs d'histoires.

**Packages principaux :**

#### `studio.core.v1.model` - Modèles de données
- `StoryPack` : Pack d'histoires complet
- `StageNode` : Nœud de scène (image/son)
- `ActionNode` : Nœud d'action (transitions)
- `Asset` / `AudioAsset` / `ImageAsset` : Ressources
- `Transition` : Transitions entre scènes
- `EnrichedPackMetadata` : Métadonnées enrichies

#### `studio.core.v1.reader` - Lecteurs de formats
- `ArchiveStoryPackReader` : Format archive (éditeur)
- `BinaryStoryPackReader` : Format binaire (appareils V1)
- `FsStoryPackReader` : Format filesystem (appareils V2/V3)

#### `studio.core.v1.writer` - Écrivains de formats
- `ArchiveStoryPackWriter`
- `BinaryStoryPackWriter`
- `FsStoryPackWriter`

#### `studio.core.v1.utils` - Utilitaires
- `AudioConversion` : Conversion audio (MP3/OGG/WAVE → WAVE)
- `ImageConversion` : Conversion image (PNG/JPEG/BMP)
- `VorbisEncoder` : Encodage OGG Vorbis
- `XXTEACipher` : Chiffrement XXTEA
- `PackAssetsCompression` : Compression des assets

#### `com.jhlabs.image` - Traitement d'image
- Quantification, palette, traitement d'image externe

**Dépendances clés :** Gson, commons-io, commons-codec, commons-compress, vorbis-java, mp3spi, jump3r

---

### 2. driver (`studio-driver`)

Pilotes de communication avec l'appareil Lunii.

**Packages principaux :**

#### `studio.driver` - Configuration
- `DeviceVersion` : Enum (V1, V2, V3, ANY)

#### `studio.driver.raw` - Driver USB bas-niveau (V1)
- `RawStoryTellerAsyncDriver` : Communication USB brute
- `LibUsbMassStorageHelper` : Helper USB mass storage

#### `studio.driver.fs` - Driver filesystem (V2/V3)
- `FsStoryTellerAsyncDriver` : Communication via stockage amovible
- `AESCBCCipher` : Chiffrement AES-CBC pour V3
- `DeviceUtils` / `FileUtils` : Utilitaires fichiers

#### `studio.driver.model` - Modèles de device
- `FsDeviceInfos` / `FsStoryPackInfos` : Infos filesystem
- `RawDeviceInfos` / `RawStoryPackInfos` : Infos raw
- `FsDeviceKeyV3` : Clés de chiffrement V3

#### `studio.driver.event` - Gestion d'événements
- `DeviceHotplugEventListener` : Détection connexion/déconnexion
- `TransferProgressListener` : Progression transfert

#### Workers USB
- `LibUsbActivePollingWorker`
- `LibUsbAsyncEventsWorker`
- `LibUsbDetectionHelper`

**Dépendances clés :** usb4java, studio-core, commons-io, commons-codec

---

### 3. agent (`studio-agent`)

Java agent pour l'instrumentation et l'intégration avec Luniistore.

**Classes principales :**
- `StudioAgent` : Agent principal (méthode `premain`)
- `UnofficialMetadataAdvice` : Intercepte `HttpURLConnection#getInputStream`
- `UnofficialImageAdvice` : Intercepte `ImageDto#getImageUrl`

**Fonctionnement :**
- Utilise ByteBuddy pour transformer les classes à runtime
- Intercepte les requêtes HTTP vers le serveur Lunii
- Redirige vers les métadonnées locales non officielles
- Permet d'afficher les packs créés avec STUdio dans Luniistore

**Dépendances clés :** byte-buddy, studio-metadata (provided), gson (provided)

---

### 4. metadata (`studio-metadata`)

Service de gestion des métadonnées de packs.

**Classes principales :**
- `DatabaseMetadataService` : Service de base de données
- `DatabasePackMetadata` : Métadonnées de pack
- `DatabaseUpdateStatusHolder` : Holder de statut de mise à jour

**Dépendances clés :** Gson

---

### 5. web-ui (`studio-web-ui`)

Interface web complète (backend Vert.x + frontend React).

#### Backend Java (Vert.x)

**Packages principaux :**

##### `studio.webui.MainVerticle` - Point d'entrée
- Démarre serveur HTTP sur port 8080
- Configure CORS, EventBus, routes REST
- Ouvre automatiquement le navigateur

##### `studio.webui.api` - Contrôleurs REST
- `DeviceController` : API device (`/api/device`)
- `LibraryController` : API bibliothèque (`/api/library`)
- `EvergreenController` : API mises à jour (`/api/evergreen`)

##### `studio.webui.service` - Services métier
- `StoryTellerService` : Service device principal
- `MockStoryTellerService` : Mock pour dev
- `LibraryService` : Service bibliothèque locale
- `EvergreenService` : Service de mises à jour

##### `studio.webui.model` - Modèles API
- `LibraryPack` : Pack de bibliothèque

**Architecture backend :**
- Vert.x 3.9.0 comme framework web réactif
- EventBus pour communication temps réel (SockJS)
- REST API pour les opérations CRUD
- Log4j2 pour le logging
- Caffeine pour le cache

#### Frontend React

**Structure :**
- `javascript/src/App.js` : Composant principal
- `javascript/src/AppContext.js` : Contexte global
- `javascript/src/actions/` : Actions Redux
- `javascript/src/reducers/` : Reducers Redux
- `javascript/src/components/` : Composants UI (45 composants)
- `javascript/src/services/` : Services API
- `javascript/src/utils/` : Utilitaires

**Technologies frontend :**
- React 16.8.6
- Redux + Redux Thunk
- @projectstorm/react-diagrams : Éditeur de diagrammes interactifs
- i18next : Internationalisation
- SockJS-client : Communication EventBus
- JSZip : Manipulation ZIP
- Dagre : Layout de graphes

**Build :**
- Node.js v12.3.1
- Yarn v1.16.0
- react-scripts 3.0.1
- Frontend Maven plugin pour intégration

**Dépendances backend clés :** Vert.x, studio-core, studio-driver, studio-metadata, studio-agent, gson, log4j2, caffeine

---

## Flux de Données

### Création de pack
1. Utilisateur crée/édite pack dans l'éditeur React (diagramme)
2. Données envoyées via REST API à `LibraryController`
3. `LibraryService` utilise `core` pour sérialiser en format Archive
4. Métadonnées stockées par `DatabaseMetadataService`

### Transfert vers appareil
1. Utilisateur drag&drop pack vers device
2. `DeviceController` reçoit la demande
3. `StoryTellerService` détecte version device (V1/V2/V3)
4. Conversion automatique du format (Archive → Binary ou FS)
5. `Driver` approprié effectue le transfert
6. Progression envoyée via EventBus temps réel

### Lecture depuis appareil
1. Device connecté → détection hotplug
2. `Driver` lit métadonnées et packs
3. Données exposées via REST API
4. Interface React affiche bibliothèque device

---

## Configuration Build

**Parent POM :**
- Version : 0.4.3-SNAPSHOT
- Java : 11 (sauf agent/metadata en Java 8)
- Packaging : pom (multi-module)

**Dépendances managées :**
- gson 2.8.5
- commons-io 2.16.1
- commons-codec 1.17.1
- commons-compress 1.27.0

**Assemblage :**
- `web-ui` crée archive de distribution avec scripts de lancement
- Scripts : `studio-linux.sh`, `studio-macos.sh`, `studio-windows.bat`
- Inclut JARs, dépendances, frontend build

---

## Points d'Extension

1. **Formats de pack** : Ajouter reader/writer dans `core`
2. **Versions device** : Étendre `DeviceVersion` + driver
3. **Conversion assets** : Ajouter convertisseurs dans `core.v1.utils`
4. **Intégrations externes** : Étendre `agent` avec nouveaux advices

---

## Formats de Packs

### Archive (Format officieux)
- Utilisé uniquement dans l'éditeur STUdio
- Format ZIP avec métadonnées JSON
- Assets non convertis

### Binary (Format officiel V1)
- Format binaire propriétaire
- Appareils firmware v1.x
- Protocole USB bas-niveau

### FS (Format officiel V2/V3)
- Système de fichiers sur stockage amovible
- Appareils firmware v2.x et v3.x
- Chiffrement AES-CBC pour V3
