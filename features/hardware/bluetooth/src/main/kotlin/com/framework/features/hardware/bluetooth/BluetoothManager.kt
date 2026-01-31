package com.framework.features.hardware.bluetooth

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.Context
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class BluetoothManager(context: Context) {
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()

    fun isBluetoothEnabled(): Boolean = bluetoothAdapter?.isEnabled ?: false

    fun getPairedDevices(): Set<BluetoothDevice> = bluetoothAdapter?.bondedDevices ?: emptySet()

    fun startDiscovery(): Boolean = bluetoothAdapter?.startDiscovery() ?: false

    fun stopDiscovery(): Boolean = bluetoothAdapter?.cancelDiscovery() ?: false
}

class BluetoothViewModel : ViewModel() {
    private val _devices = MutableStateFlow<List<BluetoothDevice>>(emptyList())
    val devices: StateFlow<List<BluetoothDevice>> = _devices.asStateFlow()

    private val _isDiscovering = MutableStateFlow(false)
    val isDiscovering: StateFlow<Boolean> = _isDiscovering.asStateFlow()

    fun updateDevices(devices: List<BluetoothDevice>) {
        _devices.value = devices
    }

    fun setDiscovering(discovering: Boolean) {
        _isDiscovering.value = discovering
    }
}
