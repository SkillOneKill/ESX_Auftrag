## Auftragssystem – Jobs mit Cooldown, Items und Belohnung
Ein simples, erweiterbares Auftragssystem, das es Spielern ermöglicht, bestimmte Jobs auszuführen. Jeder Job hat eine eigene Abklingzeit (Cooldown), benötigt bestimmte Items und belohnt den Spieler nach erfolgreichem Abschluss.

🔧 Features

✅ Anpassbare Aufträge mit Namen und Beschreibung

⏳ Individueller Cooldown pro Auftrag

🎒 Item-Voraussetzungen für jeden Job

🎁 Belohnungen nach Abschluss (Items, XP, Währung etc.)

📦 Modularer Aufbau für einfache Erweiterbarkeit


## in die items.lua rein bei Ox_inevntory

    ["auftrag_beweis"] = {
	    label = "Beweisstück",
	    weight = 1,
	    stack = true,
	    lose = true,
    },
