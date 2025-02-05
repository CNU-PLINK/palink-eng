import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:palink_v2/core/constants/app_images.dart';
import 'package:palink_v2/core/constants/persona_prompts.dart';
import 'package:palink_v2/data/api/auth/auth_api.dart';
import 'package:palink_v2/data/api/character/character_api.dart';
import 'package:palink_v2/data/api/chat/chat_api.dart';
import 'package:palink_v2/data/api/feedback/feedback_api.dart';
import 'package:palink_v2/data/api/mindset/mindset_api.dart';
import 'package:palink_v2/data/api/tip/tip_api.dart';
import 'package:palink_v2/data/api/user/user_api.dart';
import 'package:palink_v2/data/dao/character_dao.dart';
import 'package:palink_v2/data/dao/character_quest_dao.dart';
import 'package:palink_v2/data/dao/mindset_dao.dart';
import 'package:palink_v2/data/database/app_database.dart';
import 'package:palink_v2/data/entities/character_entity.dart';
import 'package:palink_v2/data/repository/auth_repositoryImpl.dart';
import 'package:palink_v2/data/repository/character_repositoryImpl.dart';
import 'package:palink_v2/data/repository/chat_repositoryImpl.dart';
import 'package:palink_v2/data/repository/feedback_repositoryImpl.dart';
import 'package:palink_v2/data/repository/openai_repositoryImpl.dart';
import 'package:palink_v2/data/repository/tip_repositoryImpl.dart';
import 'package:palink_v2/data/repository/user_repositoryImpl.dart';
import 'package:palink_v2/domain/repository/auth_repository.dart';
import 'package:palink_v2/domain/repository/character_repository.dart';
import 'package:palink_v2/domain/repository/chat_repository.dart';
import 'package:palink_v2/domain/repository/feedback_repository.dart';
import 'package:palink_v2/domain/repository/mindset_repository.dart';
import 'package:palink_v2/domain/repository/open_ai_repository.dart';
import 'package:palink_v2/domain/repository/tip_repository.dart';
import 'package:palink_v2/domain/repository/user_repository.dart';
import 'package:palink_v2/domain/usecase/create_conversation_usecase.dart';
import 'package:palink_v2/domain/usecase/fetch_characters_usecase.dart';
import 'package:palink_v2/domain/usecase/fetch_chat_history_usecase.dart';
import 'package:palink_v2/domain/usecase/generate_analyze_usecase.dart';
import 'package:palink_v2/domain/usecase/generate_initial_message_usecase.dart';
import 'package:palink_v2/domain/usecase/generate_response_usecase.dart';
import 'package:palink_v2/domain/usecase/get_ai_message_usecase.dart';
import 'package:palink_v2/domain/usecase/get_ai_messages_usecase.dart';
import 'package:palink_v2/domain/usecase/get_chatroom_by_user.dart';
import 'package:palink_v2/domain/usecase/get_feedback_by_conversation_usecase.dart';
import 'package:palink_v2/domain/usecase/get_random_mindset_usecase.dart';
import 'package:palink_v2/domain/usecase/get_user_info_usecase.dart';
import 'package:palink_v2/domain/usecase/logout_usecase.dart';
import 'package:palink_v2/domain/usecase/save_feedback_usecase.dart';
import 'package:palink_v2/domain/usecase/send_user_message_usecase.dart';
import 'package:palink_v2/domain/usecase/sign_up_usecase.dart';
import 'package:palink_v2/presentation/screens/auth/controller/login_view_model.dart';
import 'package:palink_v2/presentation/screens/auth/controller/signup_view_model.dart';
import 'package:palink_v2/presentation/screens/character_select/controller/character_select_viewmodel.dart';
import 'package:palink_v2/presentation/screens/chatting/controller/tip_viewmodel.dart';
import 'package:palink_v2/presentation/screens/mypage/controller/feedback_history_viewmodel.dart';
import 'package:palink_v2/presentation/screens/mypage/controller/myfeedbacks_viewmodel.dart';
import 'package:palink_v2/presentation/screens/mypage/controller/mypage_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repository/mindset_repositoryImpl.dart';
import '../domain/usecase/generate_tip_usecase.dart'; // Import GenerateTipUsecase
import '../domain/usecase/login_usecase.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();

  _setupDio();
  _setupApis();
  _setupRepositories(prefs);
  _setupUseCases();
  _setupViewModels();

  final database = await _setupDatabase();
  await _initializeDatabase(database.characterDao, database.mindsetDao);
}

void _setupDio() {
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(baseUrl: dotenv.env['BASE_URL']!,
      connectTimeout: const Duration(seconds: 3), // Convert Duration to milliseconds
      receiveTimeout: const Duration(seconds: 3), // Convert Duration to milliseconds
     ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("REQUEST[${options.method}] => PATH: ${options.path}");
        print("REQUEST BODY => DATA: ${options.data}");
        return handler.next(options);  // continue with the request
      },
      onResponse: (response, handler) {
        print("RESPONSE[${response.statusCode}] => DATA: ${response.data}");
        return handler.next(response);  // continue with the response
      },
      onError: (DioError e, handler) {
        print("ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}");
        print("ERROR MESSAGE: ${e.message}");
        print("ERROR BODY: ${e.response?.data}");
        return handler.next(e);  // continue with the error
      },
    ));

    return dio;
  });
}


void _setupApis() {
  getIt.registerLazySingleton<AuthApi>(() => AuthApi(getIt<Dio>()));
  getIt.registerLazySingleton<ChatApi>(() => ChatApi(getIt<Dio>()));
  getIt.registerLazySingleton<TipApi>(() => TipApi(getIt<Dio>()));
  getIt.registerLazySingleton<CharacterApi>(() => CharacterApi(getIt<Dio>()));
  getIt.registerLazySingleton<UserApi>(() => UserApi(getIt<Dio>()));
  getIt.registerLazySingleton<MindsetApi>(() => MindsetApi(getIt<Dio>()));
  getIt.registerLazySingleton<FeedbackApi>(() => FeedbackApi(getIt<Dio>()));
}

void _setupRepositories(SharedPreferences prefs) {
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt<AuthApi>(), getIt<UserApi>(), prefs));
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(prefs, getIt<UserApi>()));
  getIt.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(getIt<ChatApi>()));
  getIt.registerLazySingleton<CharacterRepository>(() => CharacterRepositoryImpl());
  getIt.registerLazySingleton<MindsetRepository>(() => MindsetRepositoryImpl(getIt<MindsetApi>()));
  getIt.registerLazySingleton<OpenAIRepository>(() => OpenAIRepositoryImpl());
  getIt.registerLazySingleton<FeedbackRepository>(() => FeedbackRepositoryImpl(getIt<FeedbackApi>()));
  getIt.registerLazySingleton<TipRepository>(() => TipRepositoryImpl(getIt<TipApi>()));
}

void _setupUseCases() {
  getIt.registerFactory<CreateConversationUseCase>(() => CreateConversationUseCase(getIt<ChatRepository>(), getIt<GetUserInfoUseCase>()));
  getIt.registerFactory<LoginUseCase>(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<SignUpUseCase>(() => SignUpUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<GetUserInfoUseCase>(() => GetUserInfoUseCase(getIt<UserRepository>()));
  getIt.registerFactory<FetchCharactersUsecase>(() => FetchCharactersUsecase(getIt<CharacterRepository>()));
  getIt.registerFactory<FetchChatHistoryUsecase>(() => FetchChatHistoryUsecase(getIt<ChatRepository>()));
  getIt.registerFactory<SendUserMessageUsecase>(() => SendUserMessageUsecase(getIt<GenerateResponseUsecase>()));
  getIt.registerFactory<GenerateResponseUsecase>(() => GenerateResponseUsecase(getIt<GetUserInfoUseCase>(), getIt<FetchChatHistoryUsecase>(), getIt<GenerateTipUsecase>()));
  getIt.registerFactory<GenerateTipUsecase>(() => GenerateTipUsecase());
  getIt.registerFactory<GenerateAnalyzeUsecase>(() => GenerateAnalyzeUsecase());
  getIt.registerFactory<GetRandomMindsetUseCase>(() => GetRandomMindsetUseCase(getIt<MindsetRepository>()));
  getIt.registerFactory<GenerateInitialMessageUsecase>(() => GenerateInitialMessageUsecase(getIt<GenerateTipUsecase>()));
  getIt.registerFactory<GetAIMessagesUsecase>(() => GetAIMessagesUsecase());
  getIt.registerFactory<GetAIMessageUsecase>(() => GetAIMessageUsecase());
  getIt.registerFactory<SaveFeedbackUseCase>(() => SaveFeedbackUseCase());
  getIt.registerFactory<GetChatroomByUser>(() => GetChatroomByUser(getIt<ChatRepository>(), getIt<UserRepository>()));
  getIt.registerFactory<GetFeedbackByConversationUsecase>(() => GetFeedbackByConversationUsecase(getIt<FeedbackRepository>()));
  getIt.registerFactory<LogoutUsecase>(() => LogoutUsecase(getIt<AuthRepository>()));
}

void _setupViewModels() {
  getIt.registerFactory<LoginViewModel>(() => LoginViewModel(loginUseCase: getIt<LoginUseCase>()));
  getIt.registerFactory<SignupViewModel>(() => SignupViewModel(signUpUseCase: getIt<SignUpUseCase>()));
  getIt.registerFactory<MypageViewModel>(() => MypageViewModel(getUserInfoUseCase: getIt<GetUserInfoUseCase>(), logoutUseCase: getIt<LogoutUsecase>()));
  getIt.registerLazySingleton<CharacterSelectViewModel>(() => CharacterSelectViewModel(fetchCharactersUsecase: getIt<FetchCharactersUsecase>()));
  getIt.registerFactory<TipViewModel>(() => TipViewModel());
  getIt.registerFactory<MyfeedbacksViewmodel>(() => MyfeedbacksViewmodel());
}

Future<AppDatabase> _setupDatabase() async {
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  getIt.registerSingleton<AppDatabase>(database);
  getIt.registerSingleton<CharacterDao>(database.characterDao);
  getIt.registerSingleton<CharacterQuestDao>(database.characterQuestDao);
  return database;
}

Future<void> _initializeDatabase(CharacterDao characterDao, MindsetDao mindsetDao) async {
  final characters = [
    CharacterEntity(
      characterId: 1,
      name: 'Miyeon',
      type: 'Emotional',
      requestStrength: 1,
      prompt: PersonaPrompts.miyeonPersona,
      description: '''#Emotional #Empathetic #Gentle_Refusal
She may feel disappointed or sad when her requests are declined.
Miyeon is introverted but warm and considerate towards her friends, building deep connections.
She doesn’t ask for help often, so when she does, it’s usually because she’s in a tough spot.
It’s important to understand and empathize with her request, and refuse gently if needed.''',
      image: ImageAssets.char1,
      quest: '''Successfully refuse a request
Try to understand the other person’s situation through conversation
Show empathy for their emotions
Provide a reasonable reason for not helping
Find a middle ground by making concessions''',
    ),
    CharacterEntity(
      characterId: 2,
      name: 'Sejin',
      type: 'Logical',
      requestStrength: 2,
      prompt: PersonaPrompts.sejinPersona,
      description: '''#Logical #Responsible #Calm
Sejin always weighs the pros and cons and believes that those who helped him should be repaid.
He tries to solve problems calmly and rationally, not letting emotions influence him.
Sejin has helped you before.
When refusing, offering a clear reason and alternatives will make it easier for Sejin to understand.''',
      image: ImageAssets.char2,
      quest: '''Successfully refuse a request
Express gratitude for past help
Incorporate emotional elements when refusing
Provide a reasonable reason for not helping
Find a middle ground by making concessions''',
    ),
    CharacterEntity(
      characterId: 3,
      name: 'Hyuna',
      type: 'Persistent',
      requestStrength: 3,
      prompt: PersonaPrompts.hyunaPersona,
      description: '''#Extroverted #TikTokStar #Honest
Hyuna is persistent and doesn’t give up easily when asking for something.
She’s honest and expresses her emotions openly.
At first, she’ll gently refuse and explain why, but as things get more intense, she needs a firm refusal.
If it’s hard to refuse, try using the 'time limit' strategy.''',
      quest: '''Successfully refuse a request
Say you don’t have enough time
Show respect for the other person’s request
Provide a reasonable reason for not helping
Clearly express your stance on persistent requests''',
      image: ImageAssets.char3,
    ),
    CharacterEntity(
      characterId: 4,
      name: 'Jinhyuk',
      type: 'Angry',
      requestStrength: 4,
      prompt: PersonaPrompts.jinhyukPersona,
      description: '''#Straightforward #Blunt #Simple
Jinhyuk’s straightforward and blunt personality often hurts his friends.
He doesn’t hide his emotions and speaks plainly.
Indecisiveness can make things worse, so be careful.
When refusing, do it clearly and firmly, keeping it simple.''',
      image: ImageAssets.char4,
      quest: '''Successfully refuse a request
Be clear in expressing your refusal
Provide logical reasons
Stick to your argument consistently
Express discomfort with the other person’s rudeness''',
    ),
  ];

  await characterDao.insertCharacters(characters);
}
