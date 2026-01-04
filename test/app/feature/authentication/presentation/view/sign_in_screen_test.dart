import 'package:auto_route/auto_route.dart';
import 'package:esignature/app/feature/authentication/presentation/riverpod/auth_provider.dart';
import 'package:esignature/app/feature/authentication/presentation/view/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock Router
class MockStackRouter extends Mock implements StackRouter {}

// Side mocks
class MockPagelessRoutesObserver extends Mock
    implements PagelessRoutesObserver {}

// Fake PageRouteInfo
class FakePageRouteInfo extends Fake implements PageRouteInfo {}

// Mock AuthController
class MockAuthController extends StateNotifier<AsyncValue<void>>
    with Mock
    implements AuthController {
  MockAuthController() : super(const AsyncValue.data(null));
}

void main() {
  late MockStackRouter mockRouter;
  late MockAuthController mockAuthController;
  late MockPagelessRoutesObserver mockPagelessRoutesObserver;

  setUpAll(() {
    registerFallbackValue(FakePageRouteInfo());
  });

  setUp(() {
    mockRouter = MockStackRouter();
    mockAuthController = MockAuthController();
    mockPagelessRoutesObserver = MockPagelessRoutesObserver();

    // Stub Router properties
    when(
      () => mockRouter.pagelessRoutesObserver,
    ).thenReturn(mockPagelessRoutesObserver);

    // Stub Router methods
    when(() => mockRouter.canPop()).thenReturn(false);
    // ignore: deprecated_member_use
    when(() => mockRouter.push(any())).thenAnswer((_) async => null);
    // ignore: deprecated_member_use
    when(() => mockRouter.replace(any())).thenAnswer((_) async => null);

    // Stub AuthController methods
    when(() => mockAuthController.login(any(), any())).thenAnswer((_) async {});
  });

  // Helper widget to wrap test target
  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authControllerProvider.overrideWith((ref) => mockAuthController),
      ],
      child: MaterialApp(
        home: StackRouterScope(
          controller: mockRouter,
          stateHash: 0,
          child: RouterScope(
            controller: mockRouter,
            inheritableObserversBuilder: () => [],
            stateHash: 0,
            child: const SignInScreen(),
          ),
        ),
      ),
    );
  }

  testWidgets('SignInScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify static text
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Log in to continue'), findsOneWidget);

    // Verify form fields
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

    // Verify button
    expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
  });

  testWidgets('SignInScreen calls login on submit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Enter text
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'test@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password123',
    );
    await tester.pump();

    // Tap Login
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
    await tester.pump();

    // Verify login called
    verify(
      () => mockAuthController.login('test@example.com', 'password123'),
    ).called(1);
  });

  testWidgets(
    'SignInScreen shows validation error logic (stubbed controller)',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap Login without entering data
      await tester.tap(find.widgetWithText(TextFormField, 'Email')); // focus
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pump();

      // Verify login NOT called
      verifyNever(() => mockAuthController.login(any(), any()));

      // Verify validation error
      expect(find.textContaining('Invalid email'), findsOneWidget);
    },
  );
}
