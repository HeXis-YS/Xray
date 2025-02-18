package io.github.saeeddev94.xray.utils

import libXray.LibXray
import java.util.Base64
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import io.github.saeeddev94.xray.utils.RunXrayRequest
import io.github.saeeddev94.xray.utils.TestXrayRequest

class XrayCore {

    private inline fun <reified T> encodeRequest(request: T): String {
        val jsonRequest = Json.encodeToString(request)
        return Base64.getEncoder().encodeToString(jsonRequest.toByteArray())
    }

    private fun decodeResponse(base64Response: String): CallResponse {
        val decodedResponse = Base64.getDecoder().decode(base64Response).decodeToString()
        return Json.decodeFromString(decodedResponse)
    }

    private fun executeXrayOperation(base64Request: String, operation: (String) -> String): String {
        val base64Response = if (base64Request.isNotEmpty) operation(base64Request) else operation()
        val response = decodeResponse(base64Response)
        return if (response.success) response.data else response.err
    }

    fun test(dir: String, config: String): String {
        val request = TestXrayRequest(datDir = dir, configPath = config)
        return executeXrayOperation(encodeRequest(request), LibXray::testXray)
    }

    fun start(dir: String, config: String, memory: Long): String {
        val request = RunXrayRequest(datDir = dir, configPath = config, maxMemory = memory)
        return executeXrayOperation(encodeRequest(request), LibXray::runXray)
    }

    fun stop(): String {
        return executeXrayOperation("", LibXray::stopXray)
    }

    fun version(): String {
        return executeXrayOperation("", LibXray::xrayVersion)
    }

    fun json(link: String): String {
        val encodedLink = Base64.getEncoder().encodeToString(link.toByteArray())
        return executeXrayOperation(encodedLink, LibXray::convertShareLinksToXrayJson)
    }

}
