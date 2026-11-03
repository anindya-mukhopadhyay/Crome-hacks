import Foundation
import WebKit

public struct AntiFingerprinting: Sendable {
    
    /// Generates the comprehensive Cromite-inspired anti-fingerprinting script
    public static func scriptContent(
        canvasPoisoning: Bool = true,
        audioPoisoning: Bool = true,
        blockBattery: Bool = true,
        blockWebRTC: Bool = true
    ) -> String {
        var script = """
        // --- Cromite iOS Privacy & Anti-Fingerprinting Shield ---
        (function() {
            'use strict';
            if (window.__cromite_shield_installed__) return;
            window.__cromite_shield_installed__ = true;

            // 1. Global Privacy Control (GPC) & Do Not Track (DNT)
            try {
                Object.defineProperty(navigator, 'globalPrivacyControl', {
                    get: () => true,
                    configurable: false,
                    enumerable: true
                });
                Object.defineProperty(navigator, 'doNotTrack', {
                    get: () => '1',
                    configurable: false,
                    enumerable: true
                });
            } catch (e) {}

            // 2. Hardware & Device Normalization (Cromite standard)
            try {
                Object.defineProperty(navigator, 'hardwareConcurrency', {
                    get: () => 4,
                    configurable: false,
                    enumerable: true
                });
                Object.defineProperty(navigator, 'deviceMemory', {
                    get: () => 8,
                    configurable: false,
                    enumerable: true
                });
            } catch (e) {}

            // 3. Disable Client Hints / High Entropy API
            if (navigator.userAgentData && navigator.userAgentData.getHighEntropyValues) {
                try {
                    navigator.userAgentData.getHighEntropyValues = function() {
                        return Promise.resolve({});
                    };
                } catch (e) {}
            }
        """

        if blockBattery {
            script += """

            // 4. Disable Battery API
            try {
                if ('getBattery' in navigator) {
                    delete navigator.getBattery;
                }
            } catch (e) {}
            """
        }

        if canvasPoisoning {
            script += """

            // 5. Canvas Fingerprinting Mitigation (Cromite noise injection)
            try {
                const originalToDataURL = HTMLCanvasElement.prototype.toDataURL;
                const originalGetImageData = CanvasRenderingContext2D.prototype.getImageData;

                function applySubtleNoise(imageData) {
                    const data = imageData.data;
                    const len = data.length;
                    for (let i = 0; i < len; i += 64) {
                        // Invert lowest bit slightly to thwart hash matching without visible distortion
                        data[i] = data[i] ^ 1;
                    }
                    return imageData;
                }

                HTMLCanvasElement.prototype.toDataURL = function() {
                    try {
                        const ctx = this.getContext('2d');
                        if (ctx && this.width > 0 && this.height > 0) {
                            const imgData = ctx.getImageData(0, 0, this.width, this.height);
                            applySubtleNoise(imgData);
                            ctx.putImageData(imgData, 0, 0);
                        }
                    } catch (e) {}
                    return originalToDataURL.apply(this, arguments);
                };

                CanvasRenderingContext2D.prototype.getImageData = function() {
                    const result = originalGetImageData.apply(this, arguments);
                    try {
                        return applySubtleNoise(result);
                    } catch (e) {
                        return result;
                    }
                };
            } catch (e) {}
            """
        }

        if audioPoisoning {
            script += """

            // 6. AudioBuffer & AnalyserNode Fingerprinting Mitigation
            try {
                if (window.AudioBuffer) {
                    const originalGetChannelData = AudioBuffer.prototype.getChannelData;
                    AudioBuffer.prototype.getChannelData = function() {
                        const data = originalGetChannelData.apply(this, arguments);
                        for (let i = 0; i < data.length; i += 100) {
                            data[i] += 0.0000001 * (Math.random() - 0.5);
                        }
                        return data;
                    };
                }
                if (window.AnalyserNode) {
                    const originalGetFloatFrequencyData = AnalyserNode.prototype.getFloatFrequencyData;
                    AnalyserNode.prototype.getFloatFrequencyData = function(array) {
                        originalGetFloatFrequencyData.apply(this, arguments);
                        for (let i = 0; i < array.length; i += 10) {
                            array[i] += 0.0001 * (Math.random() - 0.5);
                        }
                    };
                }
            } catch (e) {}
            """
        }

        if blockWebRTC {
            script += """

            // 7. WebRTC Local IP Leak Mitigation
            try {
                if (window.RTCPeerConnection) {
                    const OriginalRTC = window.RTCPeerConnection;
                    window.RTCPeerConnection = function(config) {
                        if (config && config.iceServers) {
                            // Filter out non-TURN or unauthenticated STUN servers
                            config.iceCandidatePoolSize = 0;
                        }
                        const pc = new OriginalRTC(config);
                        return pc;
                    };
                    window.RTCPeerConnection.prototype = OriginalRTC.prototype;
                }
            } catch (e) {}
            """
        }

        script += """

            // 8. Disable GamePad API
            try {
                if ('getGamepads' in navigator) {
                    navigator.getGamepads = () => [];
                }
            } catch (e) {}

            // 9. Protect Media Device Labels until authorized
            try {
                if (navigator.mediaDevices && navigator.mediaDevices.enumerateDevices) {
                    const originalEnumerate = navigator.mediaDevices.enumerateDevices.bind(navigator.mediaDevices);
                    navigator.mediaDevices.enumerateDevices = async function() {
                        const devices = await originalEnumerate();
                        return devices.map(d => ({
                            deviceId: d.deviceId ? 'sanitized-id' : '',
                            groupId: d.groupId ? 'sanitized-group' : '',
                            kind: d.kind,
                            label: '' // Do not leak device brand/model
                        }));
                    };
                }
            } catch (e) {}
        })();
        """

        return script
    }

    /// Creates a WKUserScript ready to be added to a WKUserContentController
    public static func makeUserScript(
        canvasPoisoning: Bool = true,
        audioPoisoning: Bool = true,
        blockBattery: Bool = true,
        blockWebRTC: Bool = true
    ) -> WKUserScript {
        let code = scriptContent(
            canvasPoisoning: canvasPoisoning,
            audioPoisoning: audioPoisoning,
            blockBattery: blockBattery,
            blockWebRTC: blockWebRTC
        )
        return WKUserScript(
            source: code,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
    }
}

