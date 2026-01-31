package com.framework.features.intermediate.api

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun PostsScreen(viewModel: PostViewModel) {
    val state by viewModel.posts.collectAsState()

    LaunchedEffect(Unit) {
        viewModel.loadPosts()
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text(
            text = "Posts (API Demo)",
            style = MaterialTheme.typography.headlineLarge
        )

        Spacer(modifier = Modifier.height(16.dp))

        when (state) {
            is ApiState.Loading -> {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            }

            is ApiState.Success -> {
                val posts = (state as ApiState.Success<List<Post>>).data
                LazyColumn {
                    items(posts) { post ->
                        PostCard(post)
                        Spacer(modifier = Modifier.height(8.dp))
                    }
                }
            }

            is ApiState.Error -> {
                val error = (state as ApiState.Error<List<Post>>).exception
                Column(
                    modifier = Modifier.fillMaxSize(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Text("Error: ${error.message}")
                    Spacer(modifier = Modifier.height(16.dp))
                    Button(onClick = { viewModel.retryLoad() }) {
                        Text("Reintentar")
                    }
                }
            }
        }
    }
}

@Composable
fun PostCard(post: Post) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                text = post.title,
                style = MaterialTheme.typography.titleMedium
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = post.body,
                style = MaterialTheme.typography.bodySmall,
                maxLines = 2
            )
        }
    }
}
