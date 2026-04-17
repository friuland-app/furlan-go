# Git Workflow - Furlan Go

## Branch Strategy

### Main Branches
- **main**: Branch principale per il codice di produzione. Sempre stabile e pronto per il rilascio.
- **develop**: Branch di sviluppo per l'integrazione delle feature. Pronto per il testing ma non per la produzione.

### Feature Branches
- **feature/nome-feature**: Branch per lo sviluppo di nuove funzionalità.
- **bugfix/nome-bug**: Branch per la correzione di bug.
- **hotfix/nome-hotfix**: Branch per correzioni urgenti in produzione.

## Workflow

### 1. Nuova Feature
```bash
# Crea nuovo branch da develop
git checkout develop
git pull origin develop
git checkout -b feature/nuova-funzionalità

# Sviluppa la feature
# ... lavoro ...

# Commit delle modifiche
git add .
git commit -m "Descrizione della feature"

# Push e crea Pull Request
git push origin feature/nuova-funzionalità
```

### 2. Correzione Bug
```bash
# Crea branch bugfix da develop
git checkout develop
git pull origin develop
git checkout -b bugfix/correzione-bug

# Correggi il bug
# ... lavoro ...

# Commit e push
git add .
git commit -m "Fix: descrizione della correzione"
git push origin bugfix/correzione-bug
```

### 3. Hotfix (Produzione)
```bash
# Crea branch hotfix da main
git checkout main
git pull origin main
git checkout -b hotfix/correzione-urgente

# Correggi il problema
# ... lavoro ...

# Commit e push
git add .
git commit -m "Hotfix: descrizione della correzione"
git push origin hotfix/correzione-urgente
```

## Convenzioni di Commit

### Format
```
<tipo>: <descrizione>
```

### Tipi
- **feat**: Nuova funzionalità
- **fix**: Correzione di bug
- **docs**: Modifica documentazione
- **style**: Formattazione codice (senza logica)
- **refactor**: Refactoring codice
- **test**: Aggiunta/modifica test
- **chore**: Modifiche build/configurazione

### Esempi
```
feat: aggiungere sistema cattura creature
fix: correggere posizione GPS
docs: aggiornare README
refactor: ottimizzare caricamento mappe
```

## Pull Request Process

1. **Creazione PR**: Crea PR dal branch feature verso `develop`
2. **Review**: Almeno un altro membro del team deve approvare
3. **CI/CD**: I test devono passare automaticamente
4. **Merge**: Merge dopo approvazione e risoluzione conflitti
5. **Delete Branch**: Elimina il branch dopo il merge

## Git LFS

File tracciati con Git LFS:
- Modelli 3D: *.obj, *.fbx, *.gltf, *.glb, *.blend
- Texture: *.png, *.jpg, *.jpeg, *.tga, *.psd
- Audio: *.wav, *.mp3, *.ogg

## Regole del Team

1. **Nessun commit diretto su main**: Usa sempre PR
2. **Branch piccoli**: Mantieni i branch focalizzati su una feature
3. **Commit frequenti**: Committa spesso con messaggi chiari
4. **Pull before push**: Sempre pull prima di push per evitare conflitti
5. **Code review**: Tutte le PR richiedono approvazione
6. **Test**: Assicurati che il codice funzioni prima di creare PR

## Strumenti

- **GitHub**: Hosting repository e PR
- **Git LFS**: Gestione file pesanti
- **VS Code**: Editor con integrazione Git
