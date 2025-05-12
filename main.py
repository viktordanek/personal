from flask import Flask, request, jsonify
import sqlite3

app = Flask(__name__)

# Initialize database
def init_db():
    conn = sqlite3.connect('metadata.db')
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS metadata (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            filename TEXT,
            labels TEXT
        )
    ''')
    conn.commit()
    conn.close()

@app.route('/add_metadata', methods=['POST'])
def add_metadata():
    data = request.json
    filename = data.get('filename')
    labels = ",".join(data.get('labels', []))

    conn = sqlite3.connect('metadata.db')
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO metadata (filename, labels)
        VALUES (?, ?)
    ''', (filename, labels))
    conn.commit()
    conn.close()

    return jsonify({"message": "Metadata added successfully!"}), 201

@app.route('/query_metadata', methods=['GET'])
def query_metadata():
    label = request.args.get('label')
    conn = sqlite3.connect('metadata.db')
    cursor = conn.cursor()
    cursor.execute('''
        SELECT filename, labels FROM metadata WHERE labels LIKE ?
    ''', ('%' + label + '%',))
    results = cursor.fetchall()
    conn.close()

    return jsonify(results)

if __name__ == '__main__':
    init_db()  # Initialize DB
    app.run(debug=True)
