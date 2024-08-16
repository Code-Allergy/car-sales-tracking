import React from 'react';
import { Alert } from '@/components/ui/alert';

const DemoBanner = () => {
    return (
        <Alert variant="info" className="text-center py-4">
            <strong>Demo Mode:</strong> Authentication is disabled, and the database regenerates every few hours.
        </Alert>
    );
};

export default DemoBanner;