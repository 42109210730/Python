export interface Job {
    id: string;
    job_name: string;
    company_name: string;
    company_size: string;
    // industry: string;
    salary: string;
    city: string;
    experience: string;
    degree: string;
    keywords: string[];
    isFavorite: boolean;
    favoriteLoading?: boolean;
    loading?: boolean;
    recommendReason?: string;
  }