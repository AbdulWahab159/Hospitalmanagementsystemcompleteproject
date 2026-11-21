import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

/// Application-level backend methods for patients, doctors and appointments.
/// All methods return database IDs, row counts, or lists of maps.
class HospitalService {
  HospitalService._();
  static final HospitalService instance = HospitalService._();

  Future<Database> get _db async => DatabaseHelper.instance.database;

  // -------------------- PATIENTS --------------------

  Future<int> addPatient({
    required String name,
    required int age,
    required String gender,
    required String phone,
    required String address,
  }) async {
    final db = await _db;
    return db.insert('patients', {
      'name': name.trim(),
      'age': age,
      'gender': gender.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
    });
  }

  Future<List<Map<String, Object?>>> getPatients() async {
    final db = await _db;
    return db.query('patients', orderBy: 'id DESC');
  }

  Future<int> updatePatient({
    required int id,
    required String name,
    required int age,
    required String gender,
    required String phone,
    required String address,
  }) async {
    final db = await _db;
    return db.update(
      'patients',
      {
        'name': name.trim(),
        'age': age,
        'gender': gender.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePatient(int id) async {
    final db = await _db;
    return db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------- DOCTORS --------------------

  Future<int> addDoctor({
    required String name,
    required String specialization,
    required String phone,
    required String email,
  }) async {
    final db = await _db;
    return db.insert('doctors', {
      'name': name.trim(),
      'specialization': specialization.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
    });
  }

  Future<List<Map<String, Object?>>> getDoctors() async {
    final db = await _db;
    return db.query('doctors', orderBy: 'id DESC');
  }

  Future<int> updateDoctor({
    required int id,
    required String name,
    required String specialization,
    required String phone,
    required String email,
  }) async {
    final db = await _db;
    return db.update(
      'doctors',
      {
        'name': name.trim(),
        'specialization': specialization.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteDoctor(int id) async {
    final db = await _db;
    return db.delete('doctors', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------- APPOINTMENTS --------------------

  Future<int> addAppointment({
    required int patientId,
    required int doctorId,
    required String appointmentDate, // Example: 2026-11-25
    required String appointmentTime, // Example: 10:30 AM
    required String reason,
  }) async {
    final db = await _db;
    return db.insert('appointments', {
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentDate': appointmentDate.trim(),
      'appointmentTime': appointmentTime.trim(),
      'reason': reason.trim(),
      'status': 'Pending',
    });
  }

  Future<List<Map<String, Object?>>> getAppointments() async {
    final db = await _db;
    return db.rawQuery('''
      SELECT
        appointments.id,
        appointments.patientId,
        patients.name AS patientName,
        appointments.doctorId,
        doctors.name AS doctorName,
        doctors.specialization,
        appointments.appointmentDate,
        appointments.appointmentTime,
        appointments.reason,
        appointments.status
      FROM appointments
      INNER JOIN patients ON patients.id = appointments.patientId
      INNER JOIN doctors ON doctors.id = appointments.doctorId
      ORDER BY appointments.appointmentDate DESC, appointments.id DESC
    ''');
  }

  Future<int> updateAppointmentStatus({
    required int id,
    required String status, // Pending, Approved, Completed, Cancelled
  }) async {
    const allowedStatuses = {
      'Pending',
      'Approved',
      'Completed',
      'Cancelled',
    };
    if (!allowedStatuses.contains(status)) {
      throw ArgumentError('Invalid appointment status: $status');
    }

    final db = await _db;
    return db.update(
      'appointments',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAppointment(int id) async {
    final db = await _db;
    return db.delete('appointments', where: 'id = ?', whereArgs: [id]);
  }
}
