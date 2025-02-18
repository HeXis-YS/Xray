package io.github.saeeddev94.xray.utils

import kotlinx.serialization.Serializable

@Serializable
data class CallResponse(
    val success: Boolean,
    val data: String,
    val err: String
)
