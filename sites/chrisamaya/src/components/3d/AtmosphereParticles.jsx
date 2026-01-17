import { Canvas, useFrame } from "@react-three/fiber";
import { Points, PointMaterial } from "@react-three/drei";
import { useState, useRef, useMemo } from "react";

function ParticleField(props) {
    const ref = useRef();

    // Generate random sphere positions
    const [sphere] = useState(() => {
        const positions = new Float32Array(2000 * 3);
        for (let i = 0; i < 2000; i++) {
            const radius = 1.5;
            const theta = Math.random() * Math.PI * 2;
            const phi = Math.acos(2 * Math.random() - 1);

            positions[i * 3] = radius * Math.sin(phi) * Math.cos(theta);
            positions[i * 3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
            positions[i * 3 + 2] = radius * Math.cos(phi);
        }
        return positions;
    });

    useFrame((state, delta) => {
        if (ref.current) {
            ref.current.rotation.x -= delta / 10;
            ref.current.rotation.y -= delta / 15;
        }
    });

    return (
        <group rotation={[0, 0, Math.PI / 4]}>
            <Points ref={ref} positions={sphere} stride={3} frustumCulled={false} {...props}>
                <PointMaterial
                    transparent
                    color="#4f46e5"
                    size={0.005}
                    sizeAttenuation={true}
                    depthWrite={false}
                />
            </Points>
        </group>
    );
}

export default function AtmosphereParticles() {
    return (
        <div className="fixed inset-0 z-[-1] pointer-events-none opacity-40">
            <Canvas camera={{ position: [0, 0, 1] }}>
                <ParticleField />
            </Canvas>
        </div>
    );
}
