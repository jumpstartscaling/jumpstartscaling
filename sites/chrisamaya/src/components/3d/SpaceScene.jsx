import React, { useRef } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { Stars, Float } from '@react-three/drei';

function RotatingBox() {
    const mesh = useRef();
    useFrame((state, delta) => (mesh.current.rotation.x += delta * 0.5));

    return (
        <mesh ref={mesh}>
            <boxGeometry args={[2, 2, 2]} />
            <meshStandardMaterial color="orange" wireframe />
        </mesh>
    );
}

export default function SpaceScene() {
    return (
        <div className="h-[500px] w-full bg-black rounded-lg overflow-hidden">
            <Canvas>
                <ambientLight intensity={0.5} />
                <spotLight position={[10, 10, 10]} angle={0.15} penumbra={1} />
                <Stars radius={100} depth={50} count={5000} factor={4} saturation={0} fade speed={1} />
                <Float speed={2} rotationIntensity={1} floatIntensity={2}>
                    <RotatingBox />
                </Float>
            </Canvas>
        </div>
    );
}
