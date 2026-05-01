---
noteId: "48d1936042ee11f1856b77141f89e789"
tags: []

---

# CAST - CORE

## 📌 Description

**CAST - CORE** est une bibliothèque Shell (Bash) centralisée fournissant un socle standardisé pour :

* la gestion des logs et messages
* le contrôle des erreurs
* la validation des entrées
* la gestion des dépendances système
* les opérations système (filesystem, réseau, packages)
* la structuration des scripts avec stack trace

Elle est conçue pour être utilisée comme **framework de scripting industriel**, orienté :

* automatisation DevSecOps
* conformité (ISO / bonnes pratiques)
* reproductibilité
* lisibilité et maintenance


``` mermaid
flowchart TD
    A[Script utilisateur] --> B[Initialisation contexte]
    B --> B1[Function_PATH=/]
    B --> B2[root_path]
    B --> B3[config/global.env]

    B --> C[Chargement core.sh]
    C --> D[Détection shell]
    D --> D1{Shell supporté ?}
    D1 -->|bash / zsh| E[Chargement fonctions core]
    D1 -->|sh / ksh / unknown| X[Exit]

    E --> F[check_dependencies]
    F --> F1{Dépendances OK ?}
    F1 -->|Non| X
    F1 -->|Oui| G[core_functions_loaded=1]

    G --> H[Script métier]

    H --> I[Validation entrées]
    I --> I1[do_empty_var_control]
    I1 --> I2{Variable OK ?}
    I2 -->|Non| J[set_message EdEMessage]
    I2 -->|Oui| K[Action métier]

    K --> L[Exécution commande système]
    L --> M[do_error_control]

    M --> M1{Code retour = 0 ?}
    M1 -->|Oui| N[set_message EdSMessage]
    M1 -->|Non| O{Callback fail défini ?}

    N --> P{Callback success défini ?}
    P -->|Oui| P1[Exécuter action success]
    P -->|Non| Q[Suite du script]

    O -->|Oui| O1[set_message EdEMessage non bloquant]
    O1 --> O2[Exécuter action fail]
    O -->|Non| O3[set_message EdEMessage avec niveau]
    O3 --> O4{Niveau > 0 ?}
    O4 -->|Oui| X
    O4 -->|Non| Q

    P1 --> Q
    O2 --> Q

    Q --> R[Fin / prochaine action]

    subgraph Logging[Logging centralisé]
        S1[set_message]
        S2[debug / info / check]
        S3[EdSMessage / EdWMessage / EdEMessage]
        S4[Alignement terminal]
        S5[Exit si erreur bloquante]
    end

    I1 --> S1
    M --> S1
    F --> S1
    K --> S1
```

---

## ⚙️ Fonctionnalités principales

### 🧠 Gestion des messages

* `set_message`
* format standardisé (DEBUG / INFO / CHECK / SUCCESS / WARNING / ERROR)
* gestion des couleurs + alignement dynamique terminal

### 🚨 Gestion des erreurs

* `do_error_control`
* exécution conditionnelle (success / fail hooks)
* contrôle du niveau de criticité
* support des workflows automatisés

### 🔐 Validation des entrées

* `do_empty_var_control`
* contrôle strict des variables
* mode test (non bloquant)
* gestion interne/externe

### 📂 Gestion filesystem

```mermaid
flowchart TD
    A[set_new_directory] --> B[do_check_dir_null_or_slash]
    B --> C{Chemin valide ?}

    C -->|Vide| X[EdEMessage]
    C -->|/| X
    C -->|Valide| D{Répertoire existe ?}

    D -->|Oui| E[EdSMessage Present]
    D -->|Non| F[EdWMessage Not Present]
    F --> G[mkdir -p]
    G --> H[Relance set_new_directory]
    H --> D

```

* `set_new_directory`
* `do_check_dir_null_or_slash`
* protection contre erreurs critiques (`/`, vide)

### 🌐 Téléchargement HTTP

* `get_http_object`
* gestion idempotente
* validation post-download

### 📦 Gestion APT

``` mermaid
flowchart TD
    A[do_apt_install_package] --> B[do_empty_var_control]
    B --> C[Test_apt_package_presence]
    C --> D[dpkg-query --show package]
    D --> E[do_error_control]

    E --> F{Package trouvé ?}
    F -->|Oui| G[Test_apt_package_presence_sub_i]
    G --> H[aptPackageStatus=INSTALLED]

    F -->|Non| I[Test_apt_package_presence_sub_u]
    I --> J[aptPackageStatus=NOT INSTALLED]

    H --> K{Statut package}
    J --> K

    K -->|INSTALLED| L[Aucune action]
    K -->|NOT INSTALLED| M[apt-get install -y package]
    M --> N[do_error_control]
    N --> O[set_message résultat]
```


* `do_apt_update`
* `do_apt_install_package`
* `do_apt_uninstall_package`
* `Test_apt_package_presence`

➡️ Gestion intelligente via variable globale :

``` bash
aptPackageStatus = INSTALLED / NOT INSTALLED
```

### 🔄 Modularité

* `do_load_file`
* chargement dynamique de modules

### 📏 Formatage console

* `print_header`
* `set_console_line`
* `set_spacer_message`

---

## 🧱 Architecture

```txt
CAST/
├── lib/
│   └── core.sh
├── bin/
├── config/
├── log/
├── help/
└── do_test_core.sh
```

---

## 🚀 Initialisation

### Chargement de la lib

```bash
source "${root_path}/lib/core.sh"
```

Exemple réel :

---

## 🔍 Détection environnement

La lib valide automatiquement :

* shell utilisé (bash requis)
* dépendances système (`ps`, `tput`, `date`, etc.)

Extrait :

---

## 🧪 Tests

Script de validation fourni :

```bash
./do_test_core.sh
```

Fonctions testées :

* affichage messages
* gestion erreurs
* validation variables
* gestion répertoires

Exemple :

---

## 📐 Conventions de développement

### 🔹 Shell

* Bash uniquement
* variables toujours protégées :

```bash
variable="value"
${variable}
```

### 🔹 Structures

* `if / then` sur lignes séparées
* fonctions déclarées :

```bash
function name()
{
}
```

### 🔹 Logs

* aucun `echo` direct (hors utilitaire)
* utiliser exclusivement :

``` bash
set_message
```

### 🔹 Gestion erreurs

* toujours via :

``` bash
do_error_control
```

---

## 🧩 Pattern clé : orchestration via callbacks

Exemple :

```bash
do_error_control "${?}" "" "0" "1" "" "on_fail" "on_success"
```

➡️ Permet :

* pipeline contrôlé
* comportement dynamique
* suppression du code spaghetti

---

## ⚠️ Limitations

* Bash uniquement (non POSIX)
* dépendance à `tput`
* dépendance APT (Debian-based)
* variables globales utilisées (`aptPackageStatus`, `Function_PATH`)

---

## 🔐 Bonnes pratiques intégrées

* idempotence (install / download)
* validation stricte des entrées
* logs uniformisés
* séparation logique (core vs modules)
* traçabilité (stack trace interne)

---

## 📈 Cas d’usage

* scripts d’installation automatisés
* bootstrap d’infrastructure
* pipelines DevSecOps
* tooling interne sécurisé
* POC industrialisés

---

## 🧠 Philosophie

> "Un script doit être :
>
> * prédictible
> * traçable
> * maintenable
> * sûr"

---

## 📎 Auteur / contexte

Projet orienté :

* architecture cloud
* automatisation sécurisée
* conformité (ISO / SecNumCloud)

---

## 🔚 Statut

🟢 Stable (core fonctionnel)
🟡 Évolutif (modules à étendre)

---
