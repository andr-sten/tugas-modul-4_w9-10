// lib/task_api_service.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'task_api_model.dart';

part 'task_api_service.g.dart'; // File yang akan di-generate

@RestApi(baseUrl: 'https://jsonplaceholder.typicode.com/') // Ganti dengan Mock API Anda
abstract class TaskApiService {
  factory TaskApiService(Dio dio, {String baseUrl}) = _TaskApiService;


  @POST('/todos') // Ganti /tasks
  Future<TaskDto> createTask(@Body() TaskDto task);

  @GET('/todos') // Ganti /tasks
  Future<List<TaskDto>> getTasks();

  @GET('/todos/{id}')
  Future<TaskDto> getTaskById(@Path('id') int id);

  @PUT('/todos/{id}')
  Future<TaskDto> updateTask(@Path('id') int id, @Body() TaskDto task);

  @DELETE('/todos/{id}')
  Future<void> deleteTask(@Path('id') int id);

}