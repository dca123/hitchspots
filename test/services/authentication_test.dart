import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitchspots/pages/setup_profile_page.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'authentication_test.mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

import 'firebase_app_mock.dart';

class SampleAction {
  testAction() {}
}

@GenerateMocks([SampleAction])
main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets(
    "Action is performed if user is authenticated",
    (WidgetTester tester) async {
      final String mockUserId = "someUID";
      final String mockDisplayName = "Bob";
      final mockUser = MockUser(
        isAnonymous: false,
        uid: mockUserId,
        displayName: mockDisplayName,
      );

      final mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser);
      MockSampleAction mockSampleAction = MockSampleAction();
      final mockGoogleSignIn = MockGoogleSignIn();
      final mockFireStore = FakeFirebaseFirestore();

      await mockFireStore
          .collection('users')
          .doc(mockUserId)
          .set({'uid': mockUserId, 'displayName': mockDisplayName});

      when(mockSampleAction.testAction())
          .thenAnswer((realInvocation) => () => {});

      AuthenticationState authState = AuthenticationState(
        mockSignIn: mockGoogleSignIn,
        mockFirebaseAuth: mockFirebaseAuth,
        mockFirebaseFirestore: mockFireStore,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (buildContext) {
              buildContext = buildContext;
              return Container(
                child: TextButton(
                  child: Text("test"),
                  onPressed: () async => await authState.loginFlowWithAction(
                    postLogin: mockSampleAction.testAction,
                    buildContext: buildContext,
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      verify(mockSampleAction.testAction()).called(1);
    },
  );
  testWidgets(
    "Action not performed when not authenticated",
    (WidgetTester tester) async {
      final mockFirebaseAuth = MockFirebaseAuth();
      MockSampleAction mockSampleAction = MockSampleAction();
      final mockGoogleSignIn = MockGoogleSignIn();
      final mockFireStore = FakeFirebaseFirestore();

      when(mockSampleAction.testAction())
          .thenAnswer((realInvocation) => () => {});

      AuthenticationState authState = AuthenticationState(
        mockSignIn: mockGoogleSignIn,
        mockFirebaseAuth: mockFirebaseAuth,
        mockFirebaseFirestore: mockFireStore,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (buildContext) {
              buildContext = buildContext;
              return Container(
                child: TextButton(
                  child: Text("test"),
                  onPressed: () async => await authState.loginFlowWithAction(
                    postLogin: mockSampleAction.testAction,
                    buildContext: buildContext,
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      verifyNever(mockSampleAction.testAction());
    },
  );
  testWidgets(
    "Shows setup profile page when user is not in firestore",
    (WidgetTester tester) async {
      final String mockUserId = "someUID";
      final String mockDisplayName = "Bob";
      final mockUser = MockUser(
        isAnonymous: false,
        uid: mockUserId,
        displayName: mockDisplayName,
      );

      final mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser);
      MockSampleAction mockSampleAction = MockSampleAction();
      final mockGoogleSignIn = MockGoogleSignIn();
      final mockFireStore = FakeFirebaseFirestore();

      when(mockSampleAction.testAction())
          .thenAnswer((realInvocation) => () => {});

      AuthenticationState authState = AuthenticationState(
        mockSignIn: mockGoogleSignIn,
        mockFirebaseAuth: mockFirebaseAuth,
        mockFirebaseFirestore: mockFireStore,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (buildContext) {
              buildContext = buildContext;
              return Container(
                child: TextButton(
                  child: Text("test"),
                  onPressed: () async => await authState.loginFlowWithAction(
                    postLogin: mockSampleAction.testAction,
                    buildContext: buildContext,
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(find.byType(SetupProfilePage), findsOneWidget);
    },
  );
}
