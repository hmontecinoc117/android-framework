package com.framework.features.intermediate.api

import retrofit2.http.GET
import retrofit2.http.Path

// Ejemplo: JSONPlaceholder API
data class Post(
    val userId: Int,
    val id: Int,
    val title: String,
    val body: String
)

interface PostApiService {
    @GET("posts")
    suspend fun getPosts(): List<Post>

    @GET("posts/{id}")
    suspend fun getPost(@Path("id") id: Int): Post
}
