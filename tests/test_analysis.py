"""Portable SQL regression tests (SQLite); PostgreSQL smoke test runs in CI."""
import csv
from pathlib import Path
import sqlite3
import unittest

ROOT = Path(__file__).resolve().parents[1]


def database():
    db = sqlite3.connect(':memory:')
    db.row_factory = sqlite3.Row
    db.executescript((ROOT / 'sql/00_create_tables_postgresql.sql').read_text())
    return db


def query(db, filename):
    return db.execute((ROOT / 'sql' / filename).read_text()).fetchall()


class AnalysisTests(unittest.TestCase):
    def setUp(self):
        self.db = database()

    def tearDown(self):
        self.db.close()

    def test_csv_integrity_and_all_analysis_queries(self):
        for table in ('mercadolibre_funnel', 'mercadolibre_retention'):
            with (ROOT / 'data/raw' / (table + '.csv')).open(encoding='utf-8-sig', newline='') as file:
                reader = csv.DictReader(file)
                expected = [row[1] for row in self.db.execute('PRAGMA table_info(' + table + ')')]
                self.assertEqual(reader.fieldnames, expected)
                rows = list(reader)
                self.assertTrue(rows)
                self.assertTrue(all(row['user_id'] for row in rows))
                if table.endswith('retention'):
                    keys = [(row['user_id'], row['day_after_signup']) for row in rows]
                    self.assertEqual(len(keys), len(set(keys)))
                    self.assertTrue(all(row['active'] in ('0', '1') for row in rows))
                self.db.executemany('INSERT INTO ' + table + ' VALUES (' + ','.join('?' for _ in expected) + ')',
                                    [[row[k] or None for k in expected] for row in rows])
        for name in ('02_funnel_conversion.sql', '03_funnel_por_pais.sql',
                     '04_retencion_por_pais.sql', '05_retencion_por_cohorte.sql'):
            self.assertTrue(query(self.db, name), name)

    def test_august_31_included_september_excluded_and_nested_funnel(self):
        events = [('a', 'first_visit', '2025-08-31 12:00:00'),
                  ('a', 'select_item', '2025-08-31 13:00:00'),
                  ('a', 'purchase', '2025-08-31 14:00:00'),
                  ('b', 'first_visit', '2025-09-01 00:00:00')]
        self.db.executemany('INSERT INTO mercadolibre_funnel (user_id,event_name,event_date,country) VALUES (?,?,?,\'CO\')', events)
        for name in ('02_funnel_conversion.sql', '03_funnel_por_pais.sql'):
            row = query(self.db, name)[0]
            self.assertEqual(row['usuarios_first_visit'], 1)
            self.assertEqual(row['usuarios_select_item'], 1)
            self.assertEqual(row['usuarios_purchase'], 0)  # Missing intermediate stages.

    def test_retention_exact_day_and_observed_denominator(self):
        rows = [('a', '2025-01-01', 'CO', 7, '2025-01-08', 0),
                ('a', '2025-01-01', 'CO', 14, '2025-01-15', 1),
                ('b', '2025-01-01', 'CO', 7, '2025-01-08', 1),
                ('c', '2025-08-30', 'CO', 0, '2025-08-30', 1)]
        self.db.executemany('INSERT INTO mercadolibre_retention (user_id,signup_date,country,day_after_signup,activity_date,active) VALUES (?,?,?,?,?,?)', rows)
        row = query(self.db, '04_retencion_por_pais.sql')[0]
        self.assertEqual(row['observed_d7'], 2)
        self.assertEqual(row['retention_d7_pct'], 50.0)
        self.assertEqual(row['retention_d14_pct'], 100.0)
        self.assertIsNone(row['retention_d28_pct'])
        cohorts = query(self.db, '05_retencion_por_cohorte.sql')
        self.assertEqual(cohorts[0]['retention_d7_pct'], 50.0)
        self.assertIsNone(cohorts[1]['retention_d7_pct'])

    def test_empty_funnel_is_null_not_division_error(self):
        self.assertIsNone(query(self.db, '02_funnel_conversion.sql')[0]['conversion_purchase'])


if __name__ == '__main__':
    unittest.main()
