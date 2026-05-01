# Regelwerk

Framework: Flutter 3.41.7
Dart: 3.11.5

---

## 1. Allgemeines
* Mach dir zuerst einen Plan und stelle diesen haargenau dar, bevor du mit der Implementierung beginnst.
* Belege alle Entscheidungen mit Quellen.
* Sollten dir Informationen Fehlen dann frag zuerst nach bevor du einen Plan erstellst.
* Bei unzureichenden Informationen oder Fehlenden Informationen fügst du keine eigenen Interpretationen hinzu.

## 2. Architektur & State Management
* **Architektur-Muster**: Wir nutzen **Clean Architecture** (Data, Domain, Presentation). Es wird mit MVVM Design-Pattern entwickelt. Die Ordnerstruktur folgt dem Feature-First Ansatz.
* **State Management**: Beim State Management kommt **BloC** zum Einsatz.
* **Logik-Trennung**: Geschäftslogik gehört in den Cubit.

## 3. Coding Standards & Best Practices
* **Immutability**: Nutze `final` für alle Variablen, die sich nicht ändern. Verwende `const` Konstruktoren, wo immer möglich.
* **Null Safety**: Der Code muss striktes Sound Null Safety einhalten.
* **Type** es wird bei jeder Variable oder Methoden immer der Typ definiert.
* **Naming Conventions**:
    * Klassen: `PascalCase`
    * Variablen & Methoden: `camelCase`
    * Dateien: `snake_case.dart`
* **Extensions**: Bevorzuge Extension-Methods für wiederkehrende Logik auf Standard-Typen (z.B. `String`, `BuildContext`).
* **Mixins**: Verwende Mixins wenn Klassen ähnliche Funktionen oder Widgets ähnliche Funktionen haben.
* **DI**: Benutze eine saubere Struktur die Dependency Injection über den Konstruktor übergibt. Für die Zentrale Haltung von Services kann get_it und injectable als DI Unterstützung erfolgen.

## 4. Error Handling & Testing
* **Fehlerbehandlung**: Nutze `Either` für das Fehlerhandling so dass dieses sauber zu erkennen ist.
* **Testing**: 
    * **BDD**: Es sollen alle Repositories, View Models, oder Datenstrukturen mit sinnvollen Unit-Tests geprüft werden. Widget tests werden nur generiert um das Verhalten oder die Funktion zu prüfen, aber nicht um die UI zu testen.
    * Logik muss mit **Unit Tests** abgedeckt werden.
    * Kritische UI-Komponenten erhalten **Widget Tests**.

## 5. Spezifische Anweisungen für die KI
* **Code-Generierung**: Wenn du Code generierst, füge immer die notwendigen Imports hinzu.
* **Kommentare**: Kommentiere komplexere Logik kurz und präzise auf Englisch.
* **Pakete**: Nutze nur offizielle Pakete von `pub.dev` (z.B. `freezed` für Models, `get_it` für DI). Achte darauf das diese nicht von `unverified uploader` sind. Verwende nur Pakete die tatsächlich notwendig sind. Stelle sicher das die Pakete die verwendet werden auch kompatibel zu einander sind.

---