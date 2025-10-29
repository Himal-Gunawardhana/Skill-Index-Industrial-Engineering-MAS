import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDiagnosticScreen extends StatefulWidget {
  const FirebaseDiagnosticScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseDiagnosticScreen> createState() =>
      _FirebaseDiagnosticScreenState();
}

class _FirebaseDiagnosticScreenState extends State<FirebaseDiagnosticScreen> {
  Map<String, dynamic> diagnosticResults = {};
  bool isChecking = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() => isChecking = true);

    Map<String, dynamic> results = {};

    // Check 1: Firebase Initialization
    try {
      final app = Firebase.app();
      results['firebase_init'] = {
        'status': 'success',
        'message': 'Firebase is initialized',
        'project_id': app.options.projectId,
        'app_id': app.options.appId,
      };
    } catch (e) {
      results['firebase_init'] = {
        'status': 'error',
        'message': 'Firebase not initialized: $e',
      };
    }

    // Check 2: Firebase Authentication
    try {
      // Try to get auth instance
      final auth = FirebaseAuth.instance;
      results['auth_instance'] = {
        'status': 'success',
        'message': 'Auth instance created',
      };

      // Try a test registration (will fail but we can see why)
      try {
        await auth.createUserWithEmailAndPassword(
          email: 'test_diagnostic_${DateTime.now().millisecondsSinceEpoch}@test.com',
          password: 'test123456',
        );
        // If this succeeds, delete the test user
        await auth.currentUser?.delete();
        results['auth_test'] = {
          'status': 'success',
          'message': 'Authentication is ENABLED and working!',
        };
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'operation-not-allowed') {
            results['auth_test'] = {
              'status': 'error',
              'message': '❌ Email/Password authentication is NOT ENABLED',
              'code': e.code,
              'details': e.message,
              'solution':
                  'Go to Firebase Console → Authentication → Sign-in method → Enable Email/Password',
            };
          } else {
            results['auth_test'] = {
              'status': 'warning',
              'message': 'Auth error: ${e.code}',
              'code': e.code,
              'details': e.message,
            };
          }
        } else {
          results['auth_test'] = {
            'status': 'error',
            'message': 'Auth error: $e',
          };
        }
      }
    } catch (e) {
      results['auth_instance'] = {
        'status': 'error',
        'message': 'Cannot create Auth instance: $e',
      };
    }

    // Check 3: Firestore
    try {
      final firestore = FirebaseFirestore.instance;
      results['firestore_instance'] = {
        'status': 'success',
        'message': 'Firestore instance created',
      };

      // Try to read from Firestore
      try {
        await firestore.collection('_diagnostic_test').limit(1).get();
        results['firestore_test'] = {
          'status': 'success',
          'message': 'Firestore is ENABLED and accessible!',
        };
      } catch (e) {
        results['firestore_test'] = {
          'status': 'error',
          'message': '❌ Firestore might not be enabled',
          'details': e.toString(),
          'solution':
              'Go to Firebase Console → Firestore Database → Create Database',
        };
      }
    } catch (e) {
      results['firestore_instance'] = {
        'status': 'error',
        'message': 'Cannot create Firestore instance: $e',
      };
    }

    setState(() {
      diagnosticResults = results;
      isChecking = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isChecking ? null : _runDiagnostics,
            tooltip: 'Re-run diagnostics',
          ),
        ],
      ),
      body: isChecking
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Running diagnostics...'),
                ],
              ),
            )
          : diagnosticResults.isEmpty
              ? const Center(child: Text('No diagnostic results'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Firebase Configuration Check',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This diagnostic will tell you exactly what needs to be fixed in Firebase Console.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ...diagnosticResults.entries.map((entry) {
                      final data = entry.value as Map<String, dynamic>;
                      final status = data['status'] as String;
                      final message = data['message'] as String;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getStatusIcon(status),
                                    color: _getStatusColor(status),
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getCheckTitle(entry.key),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          message,
                                          style: TextStyle(
                                            color: _getStatusColor(status),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (data.containsKey('project_id')) ...[
                                const SizedBox(height: 8),
                                Text('Project ID: ${data['project_id']}',
                                    style: const TextStyle(fontSize: 12)),
                              ],
                              if (data.containsKey('code')) ...[
                                const SizedBox(height: 8),
                                Text('Error Code: ${data['code']}',
                                    style: const TextStyle(fontSize: 12)),
                              ],
                              if (data.containsKey('details')) ...[
                                const SizedBox(height: 8),
                                Text('Details: ${data['details']}',
                                    style: const TextStyle(fontSize: 12)),
                              ],
                              if (data.containsKey('solution')) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.lightbulb_outline,
                                          color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          data['solution'],
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    const Card(
                      color: Colors.blue,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📋 Quick Fix Steps:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              '1. Go to Firebase Console\n'
                              '2. Select project: ie-skill-index\n'
                              '3. Enable Authentication → Email/Password\n'
                              '4. Create Firestore Database (Test mode)\n'
                              '5. Return here and click refresh',
                              style: TextStyle(
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  String _getCheckTitle(String key) {
    switch (key) {
      case 'firebase_init':
        return 'Firebase Initialization';
      case 'auth_instance':
        return 'Authentication Instance';
      case 'auth_test':
        return 'Authentication Test';
      case 'firestore_instance':
        return 'Firestore Instance';
      case 'firestore_test':
        return 'Firestore Access Test';
      default:
        return key;
    }
  }
}
