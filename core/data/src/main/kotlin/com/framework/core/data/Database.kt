package com.framework.core.data

import androidx.room.Database
import androidx.room.RoomDatabase

// Entidades de ejemplo
@androidx.room.Entity(tableName = "items")
data class ItemEntity(
    @androidx.room.PrimaryKey(autoGenerate = true) val id: Long = 0,
    val name: String,
    val description: String
)

// DAO
@androidx.room.Dao
interface ItemDao {
    @androidx.room.Insert
    suspend fun insert(item: ItemEntity)

    @androidx.room.Query("SELECT * FROM items")
    suspend fun getAllItems(): List<ItemEntity>

    @androidx.room.Delete
    suspend fun delete(item: ItemEntity)
}

// Database
@Database(entities = [ItemEntity::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun itemDao(): ItemDao
}
