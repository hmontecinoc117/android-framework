package com.framework.features.intermediate.api

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed class ApiState<T> {
    class Loading<T> : ApiState<T>()
    data class Success<T>(val data: T) : ApiState<T>()
    data class Error<T>(val exception: Exception) : ApiState<T>()
}

class PostViewModel(private val apiService: PostApiService) : ViewModel() {
    private val _posts = MutableStateFlow<ApiState<List<Post>>>(ApiState.Loading())
    val posts: StateFlow<ApiState<List<Post>>> = _posts.asStateFlow()

    fun loadPosts() {
        viewModelScope.launch {
            _posts.value = ApiState.Loading()
            try {
                val postList = apiService.getPosts()
                _posts.value = ApiState.Success(postList)
            } catch (e: Exception) {
                _posts.value = ApiState.Error(e)
            }
        }
    }

    fun retryLoad() {
        loadPosts()
    }
}
