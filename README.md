# 📦 bkmedia.sh - Media Backup & Restore Script

## 📌 Prerequisites

Before using `bkmedia.sh`, ensure you have:
- SSH access to all backup locations (public SSH keys must be set up on remote servers).

## 🎯 Features

- 📂 **Backup media files** from multiple remote servers.
- 🔄 **Restore backups** from the most recent snapshots.
- 🔢 **Select specific locations** to backup or restore using line numbers.
- 👽 **Alien File Handling**: Detects, compresses, and logs `.xyzar` files, ensuring intergalactic data is preserved.

## 🛠️ Installation

Clone this repository and navigate to the script directory:

```bash
git clone https://github.com/thatdevguy1/backup-script
cd backup-script
chmod +x bkmedia.sh
```

## 📝 Configuration

Use `locations.cfg` file to specify backup sources:

```
[user]@[server-host]:[path]
```

Example:
```
john@server1.com:/media/photos
alice@backup.net:/home/alice/videos
```

## 🚀 Usage

### 📜 List Configured Locations
```bash
./bkmedia.sh
```

### 📦 Backup All Locations
```bash
./bkmedia.sh -B
```

### 🎯 Backup a Specific Location
```bash
./bkmedia.sh -B -L 2  # Backup only the location at line 2
```

### 🎯 Restore from a Specific Location
```bash
./bkmedia.sh -R 1 -L 2  # Restore from line 2's backup
```

## 👽 Alien File Handling

- Detects `.xyzar` files (5x the size of normal media files 🛸).
- Compresses `.xyzar` files before backup.
- Generates detailed reports on `.xyzar` file size reduction.
- Stores logs in `alien_logs`.

## 📜 Example Alien Log Entry

```
Timestamp: 2025-04-01 14:30:00
Source: john@server1.com:/media/photos
Original Size: 500MB
Compressed Size: 100MB
```

## 🛠️ Troubleshooting

- **Ensure SSH keys are set up** on all remote servers.
- **Check `locations.cfg`** for correct formatting.
- **Verify `alien_logs`** for `.xyzar` file reports.

## 📜 License

This project is licensed under the MIT License. See `LICENSE` for details.

🚀 *Handle your backups like a pro, and may the force be with you!* ✨


