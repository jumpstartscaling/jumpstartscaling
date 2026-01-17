import { Canvas, useFrame } from "@react-three/fiber";
import { Points, PointMaterial } from "@react-three/drei";
import { useState, useRef } from "react";
import * as random from "maath/random/dist/maath-random.esm";

function ParticleField(props) {
    const ref = useRef();

    // Generate robust sphere positions using maath
    const [sphere] = useState(() => {
        // Generate 3000 points on a sphere of radius 1.5
        // Using float32array directly ensures typed array compatibility
        const data = random.inSphere(new Float32Array(3000 * 3), { radius: 1.5 });

        // Safety check for NaN values to prevent Three.js bounding sphere errors
        for (let i = 0; i < data.length; i++) {
            if (isNaN(data[i])) data[i] = 0;
        }
        return data;
    });

    useFrame((state, delta) => {
        if (ref.current) {
            ref.current.rotation.x -= delta / 15;
            ref.current.rotation.y -= delta / 20;
        }
    });

    return (
        <group rotation={[0, 0, Math.PI / 4]}>
            <Points ref={ref} positions={sphere} stride={3} frustumCulled={false} {...props}>
                <PointMaterial
                    transparent
                    color="#6366f1"
                    size={0.003}
                    sizeAttenuation={true}
                    depthWrite={false}
                    blending={2} // AdditiveBlending
                />
            </Points>
        </group>
    );
}

export default function AtmosphereParticles() {
    return (
        <div className="fixed inset-0 z-[-1] pointer-events-none opacity-60">
            <Canvas camera={{ position: [0, 0, 1] }} dpr={[1, 2]} gl={{ antialias: false }}>
                <ParticleField />
            </Canvas>
        </div>
    );
}
